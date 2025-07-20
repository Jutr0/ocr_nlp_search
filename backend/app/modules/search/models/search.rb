require 'digest'

module Search
  class Search
    INDEX_DIR = "search"

    def initialize
      FileUtils.mkdir_p(INDEX_DIR)
      @current_generation = 0
      @documents = []
      @words = {}
    end

    def index(sentence, id)
      mapped_sentence = sentence.downcase.gsub(/[^a-z0-9\s]/i, '')

      docIdx = @documents.length

      @documents << id

      mapped_sentence.split(" ").each do |word|
        next if word.length < 2

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
      # index search through all files like lucene
    end

    def flush!
      # current implementation will work with pointers to specific line in document so some files are not necessary but lets leave it to keep lucene's flow
      # for V2 this will point to block and offset in each file ( same as in lucene )

      field_pointers = create_field_data
      field_metadata_pointers = create_field_metadata(field_pointers)
      create_field_index(field_metadata_pointers)

      term_info = create_doc_values
      term_prefixes_positions = create_term_info(term_info)
      create_term_index(term_prefixes_positions)

      @current_generation += 1
    end

    def self.kaboom_files!
      FileUtils.rm_rf(INDEX_DIR) if File.exist?(INDEX_DIR)
    end

    private

    def create_field_data

      field_data = File.new("#{INDEX_DIR}/_#{@current_generation}.fdt", "w+")
      field_data.write(@documents.join("\n"))
      Array.new(@documents.length) { |i| i + 1 }
    end

    def create_field_metadata(field_pointers)
      field_metadata = File.new("#{INDEX_DIR}/_#{@current_generation}.fnm", "w+")
      field_metadata.write(field_pointers.join("\n"))
      field_pointers
    end

    def create_field_index(field_metadata_pointers)

      field_index = File.new("#{INDEX_DIR}/_#{@current_generation}.fdi", "w+")
      i = 0
      while i < @documents.length
        field_index.write("#{i} #{field_metadata_pointers[i]}\n")
        i += 1
      end
    end

    def create_doc_values
      doc_values = File.new("#{INDEX_DIR}/_#{@current_generation}.doc", "w+")
      current_line = 1
      term_info = {}
      @words.sort_by(&:first).each do |word, documentsIdxs|
        term_info[word] = { doc_freq: documentsIdxs.length, doc_start_fp: current_line }
        documentsIdxs.each do |documentIdx, values|
          doc_values.write("#{documentIdx} #{values[:freq]}\n")
          current_line += 1
        end
      end
      term_info
    end

    def create_term_info(term_info)
      term_info_file = File.new("#{INDEX_DIR}/_#{@current_generation}.tim", "w+")
      term_prefixes_positions = {}
      current_line = 1
      term_info.each do |word, info|
        if term_prefixes_positions[word[0..1]].nil?
          term_prefixes_positions[word[0..1]] = { start_pos: current_line }
        end

        term_info_file.write("#{word} #{info[:doc_freq]} #{info[:doc_start_fp]}\n")
        current_line += 1
      end

      term_prefixes_positions
    end
    def create_term_index(term_prefixes_positions)
      term_index_file = File.new("#{INDEX_DIR}/_#{@current_generation}.tip", "w+")
      term_prefixes_positions.each do |prefix, values|
        term_index_file.write("#{prefix} #{values[:start_pos]}\n")
      end
    end

  end
end