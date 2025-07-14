namespace :documents do
  desc "Index all documents to search engine"
  task index: :environment do
    indexer = Search::Search.new

    Documents::Document.find_each do |doc|
      indexer.index({
                      id: doc.id,
                      filename: doc.filename,
                      text_ocr: doc.text_ocr }.to_json
      )
    end

    puts "Indexed #{Documents::Document.count} documents"
  end
end