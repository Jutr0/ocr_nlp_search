require 'digest'

module Search
  class Search

    class Paths
      BASE_DIR = "search"
      WORDS_DIR = "#{BASE_DIR}/words"
      DOCUMENTS_DIR = "#{BASE_DIR}/documents"
      GRAVEYARD_DIR = "#{BASE_DIR}/graveyard"
      WORDS = "#{WORDS_DIR}/words.json"
      DOCUMENTS = "#{DOCUMENTS_DIR}/documents.json"
      GRAVEYARD = "#{GRAVEYARD_DIR}/.graveyard"
    end

    def initialize
      FileUtils.mkdir_p(Paths::WORDS_DIR)
      FileUtils.mkdir_p(Paths::DOCUMENTS_DIR)

      @documents = {}
      @words = {}
    end

    def index(sentence)
      mapped_sentence = sentence.downcase.gsub(/[^a-z0-9\s]/i, '')

      document_hash = Digest::SHA256.hexdigest(sentence)
      @documents[document_hash] = sentence

      mapped_sentence.split(" ").each do |word|
        next if word.length < 3
        prefix = word[0..2]
        @words[prefix] ||= {}
        if @words[prefix][word].present?
          @words[prefix][word] << document_hash
        else
          @words[prefix][word] = [document_hash]
        end
      end
    end

    def search(query)
      documents = JSON.parse(File.read(Paths::DOCUMENTS))
      mapped_query = query.downcase.gsub(/[^a-z0-9\s]/i, '')
      loaded_words_files = {}
      found_documents = []
      mapped_query.split(" ").each do |word|
        next if word.length < 3

        prefix = word[0..2]
        if loaded_words_files[prefix].present?
          words = loaded_words_files[prefix]
        else
          if File.exist?(get_words_file_path(prefix))
            words_file = File.read(get_words_file_path(prefix))
            words = JSON.parse(words_file)
          else
            words = {}
          end
          loaded_words_files[prefix] = words
        end

        found_documents.concat(words[word]) if words[word].present?
      end

      found_documents.uniq.map do |document_hash|
        documents[document_hash]
      end
    end

    def flush!
      documents_json = @documents.to_json
      @documents = {}

      FileUtils.mkdir_p(Paths::DOCUMENTS_DIR)
      File.write(Paths::DOCUMENTS, documents_json)
      flush_words

    end

    def self.kaboom_files!
      FileUtils.rm_rf(Paths::BASE_DIR) if File.exist?(Paths::BASE_DIR)
    end

    private

    def flush_words
      # inefficient but for V1 will be fine
      # also in next iteration remember about flock or sth similar

      @words.each do |prefix, words|
        if File.exist?(get_words_file_path(prefix))
          file = File.read(get_words_file_path(prefix))
          current_words = JSON.parse(file)
        else
          current_words = {}
        end
        words.each do |word, documents|
          if current_words[word].present?
            current_words[word] = (current_words[word] + documents).uniq
          else
            current_words[word] = documents.uniq
          end
        end

        File.write(get_words_file_path(prefix), current_words.to_json)
      end
      @words = {}

    end

    def get_words_file_path(prefix)
      Paths::WORDS_DIR + "/#{prefix}.json"
    end

  end
end