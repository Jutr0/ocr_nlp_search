require "digest"

module Search
  class Search
    INDEX_DIR = "search"
    MIN_WORD_LENGTH = 2

    def initialize
      FileUtils.mkdir_p(INDEX_DIR)
      @current_generation = 0
      @documents = []
      @words = {}
    end

    def index(sentence, id)
      mapped_sentence = sentence.downcase.gsub(/[^a-z0-9\s]/i, "")

      docIdx = @documents.length

      @documents << id

      mapped_sentence.split(" ").each do |word|
        next if word.length < MIN_WORD_LENGTH

        @words ||= {}
        if @words[word].present?
          if @words[word][docIdx].present?
            @words[word][docIdx][:freq] += 1
          else
            @words[word][docIdx] = { freq: 1 }
          end
        else
          @words[word] = { docIdx => { freq: 1 } }
        end
      end
    end

    def search(query)
      segments_path = get_current_segments_file

      raise "No segments file found" if segments_path.nil?

      query = query.downcase.gsub(/[^a-z0-9\s]/i, "")

      segments = JSON.parse(File.read(segments_path))
      document_ids = []

      # In V2 this will search through segments concurrently
      segments["segments"].each do |segment|
        document_ids.concat(search_in_segment(segment["name"], query))
      end
      document_ids
    end

    def flush!
      # current implementation will work with pointers to specific line in document so some files are not necessary but lets leave it to keep lucene's flow
      # for V2 this will point to block and offset in each file ( same as in lucene )

      segments_path = get_current_segments_file
      if segments_path.nil?
        create_segments_info(0)
        @current_generation = 0
      else
        current_generation = get_current_generation(segments_path)
        segments = JSON.parse(File.read(segments_path))
        @current_generation = segments["name_count"]

        create_segments_info(current_generation + 1, segments)
      end

      field_pointers = create_field_data
      field_metadata_pointers = create_field_metadata(field_pointers)
      create_field_index(field_metadata_pointers)

      term_info = create_doc_values
      term_prefixes_positions = create_term_info(term_info)
      create_term_index(term_prefixes_positions)

      @documents = []
      @words = {}
    end

    def self.kaboom_files!
      FileUtils.rm_rf(INDEX_DIR) if File.exist?(INDEX_DIR)
    end

    private

    def search_in_segment(segment_name, query)
      document_ids = []

      query.split(" ").each do |word|
        next if word.length < MIN_WORD_LENGTH

        term_info_position = get_term_info_position(segment_name, word[0...MIN_WORD_LENGTH])
        next if term_info_position == -1

        term_doc_info = get_term_doc_info(segment_name, term_info_position, word)
        next if term_doc_info.nil?

        doc_ids = get_doc_ids(segment_name, term_doc_info)

        doc_ids.each do |doc_id|
          doc_metadata_position = get_doc_metadata_position(segment_name, doc_id)
          doc_data_position = get_doc_data_position(segment_name, doc_metadata_position)
          document_ids << get_doc_data(segment_name, doc_data_position)
        end

      end

      document_ids
    end

    def get_term_info_position(segment_name, prefix)
      file = File.read("#{INDEX_DIR}/#{segment_name}.tip")

      # this should use binary search
      file.lines.each do |line|
        if line.split(" ")[0] == prefix
          return line.split(" ")[1].to_i
        end
      end

      -1
    end

    def get_term_doc_info(segment_name, term_info_position, word)
      # Also, ideally, here should load to memory only the necessary block where this word is located

      file = File.read("#{INDEX_DIR}/#{segment_name}.tim")
      i = term_info_position
      while i < file.lines.length
        line_parts = file.lines[i].split(" ")
        if line_parts[0] == word
          return { doc_freq: line_parts[1].to_i, doc_start_fp: line_parts[2].to_i }
        end
        i += 1
      end
    end

    def get_doc_ids(segment_name, term_doc_info)
      # same should load only part of the file
      file = File.read("#{INDEX_DIR}/#{segment_name}.doc")

      doc_ids = []
      i = term_doc_info[:doc_start_fp]
      while i < term_doc_info[:doc_start_fp] + term_doc_info[:doc_freq]
        doc_ids << file.lines[i].split(" ")[0].to_i
        i += 1
      end

      doc_ids
    end

    def get_doc_metadata_position(segment_name, doc_id)
      # this actually has to load the whole file and search for doc id

      file = File.read("#{INDEX_DIR}/#{segment_name}.fdi")
      file.lines.each do |line|
        if line.split(" ")[0] == doc_id.to_s
          return line.split(" ")[1].to_i
        end
      end
    end

    def get_doc_data_position(segment_name, doc_metadata_position)
      # here we have exact position so only part of the file could be loaded

      file = File.read("#{INDEX_DIR}/#{segment_name}.fdm")
      file.lines[doc_metadata_position].to_i
    end

    def get_doc_data(segment_name, doc_data_position)
      # especially here only one block should be loaded...
      file = File.read("#{INDEX_DIR}/#{segment_name}.fdt")
      file.lines[doc_data_position].chomp
    end

    def get_current_segments_file
      files = Dir.entries(INDEX_DIR).select { |f| f =~ /^segments_(\d+)$/ }

      return nil if files.empty?

      current_segment = files.max_by do |f|
        f.match(/^segments_(\d+)$/)[1].to_i
      end

      "#{INDEX_DIR}/#{current_segment}"
    end

    def get_current_generation(segments_path)
      File.basename(segments_path).match(/^segments_(\d+)$/)[1].to_i
    end

    def create_segments_info(generation, current_segments_info = nil)

      if current_segments_info.nil?
        new_segments_info = { name_count: 1, segments: [name: "_0", max_docs: @documents.length, dels: 0, del_gen: -1] }
      else
        new_segments_info = current_segments_info.dup
        new_segments_info["name_count"] += 1
        new_segments_info["segments"] << { name: "_#{generation}", max_docs: @documents.length, dels: 0, del_gen: -1 }
      end

      File.open("#{INDEX_DIR}/segments_#{generation}", "w") do |f|
        f.write(new_segments_info.to_json)
      end
    end

    def create_field_data
      File.open("#{INDEX_DIR}/_#{@current_generation}.fdt", "w") do |f|
        f.write(@documents.join("\n"))
      end
      Array.new(@documents.length) { |i| i }
    end

    def create_field_metadata(field_pointers)
      File.open("#{INDEX_DIR}/_#{@current_generation}.fdm", "w") do |f|
        f.write(field_pointers.join("\n"))
      end
      field_pointers
    end

    def create_field_index(field_metadata_pointers)

      File.open("#{INDEX_DIR}/_#{@current_generation}.fdi", "w") do |f|
        i = 0
        while i < field_metadata_pointers.length
          f.write("#{i} #{field_metadata_pointers[i]}\n")
          i += 1
        end
      end

    end

    def create_doc_values
      term_info = {}

      File.open("#{INDEX_DIR}/_#{@current_generation}.doc", "w") do |f|
        current_line = 0
        @words.sort_by(&:first).each do |word, documentsIdxs|
          term_info[word] = { doc_freq: documentsIdxs.length, doc_start_fp: current_line }
          documentsIdxs.each do |documentIdx, values|
            f.write("#{documentIdx} #{values[:freq]}\n")
            current_line += 1
          end
        end
      end

      term_info
    end

    def create_term_info(term_info)
      term_prefixes_positions = {}

      File.open("#{INDEX_DIR}/_#{@current_generation}.tim", "w") do |f|
        current_line = 0
        term_info.each do |word, info|
          prefix = word[0...MIN_WORD_LENGTH]
          if term_prefixes_positions[prefix].nil?
            term_prefixes_positions[prefix] = { start_pos: current_line }
          end

          f.write("#{word} #{info[:doc_freq]} #{info[:doc_start_fp]}\n")
          current_line += 1
        end

      end

      term_prefixes_positions
    end

    def create_term_index(term_prefixes_positions)
      File.open("#{INDEX_DIR}/_#{@current_generation}.tip", "w") do |f|
        term_prefixes_positions.each do |prefix, values|
          f.write("#{prefix} #{values[:start_pos]}\n")
        end
      end
    end

  end
end