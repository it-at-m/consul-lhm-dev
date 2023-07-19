class CreateResourceSentiments < ActiveRecord::Migration[5.2]
  def change
    create_table :resource_sentiments do |t|
      t.references :sentiment, foreign_key: true, index: { name: "index_resource_sentiments_on_sentiment" }
      t.references :sentimentable, polymorphic: true,
        index: { name: "index_resource_sentiments_on_sentimentable" }

      t.timestamps
    end
  end
end
