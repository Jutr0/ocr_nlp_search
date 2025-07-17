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
      @documents = {}
      @words = {}
    end

    def index(sentence)
      mapped_sentence = sentence.downcase.gsub(/[^a-z0-9\s]/i, '')

      document_hash = Digest::SHA256.hexdigest(sentence)
      @documents[document_hash] = sentence

      mapped_sentence.split(" ").each do |word|
        if @words[word].present?
          @words[word] << document_hash
        else
          @words[word] = [document_hash]
        end
      end
    end

    def search(query)
      words = JSON.parse(File.read(Paths::WORDS))
      documents = JSON.parse(File.read(Paths::DOCUMENTS))
      mapped_query = query.downcase.gsub(/[^a-z0-9\s]/i, '')

      found_documents = []
      mapped_query.split(" ").each do |word|
        found_documents.concat(words[word]) if words[word].present?
      end

      found_documents.uniq.map do |document_hash|
        documents[document_hash]
      end
    end

    def flush!
      words_json = @words.to_json
      @words = {}
      documents_json = @documents.to_json
      @documents = {}

      FileUtils.mkdir_p(Paths::WORDS_DIR)
      File.write(Paths::WORDS, words_json)
      FileUtils.mkdir_p(Paths::DOCUMENTS_DIR)
      File.write(Paths::DOCUMENTS, documents_json)

    end

  end
end