class CreateSentiments < ActiveRecord::Migration[5.2]
  def change
    create_table :sentiments do |t|
      t.string :color
      t.references :projekt_phase, foreign_key: true

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        Sentiment.create_translation_table! name: :string
      end

      dir.down do
        Sentiment.drop_translation_table!
      end
    end
  end
end
