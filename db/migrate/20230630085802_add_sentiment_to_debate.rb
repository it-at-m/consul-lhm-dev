class AddSentimentToDebate < ActiveRecord::Migration[5.2]
  def change
    add_reference :debates, :sentiment, foreign_key: true
  end
end
