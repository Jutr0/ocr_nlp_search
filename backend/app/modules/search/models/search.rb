require 'digest'

module Search
  class Search
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
      mapped_query = query.downcase.gsub(/[^a-z0-9\s]/i, '')

      found_documents = []
      mapped_query.split(" ").each do |word|
        found_documents.concat(@words[word]) if @words[word].present?
      end

      found_documents.uniq.map do |document_hash|
        @documents[document_hash]
      end
    end

  end
end