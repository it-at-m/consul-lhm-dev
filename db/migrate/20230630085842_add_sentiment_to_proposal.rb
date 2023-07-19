class AddSentimentToProposal < ActiveRecord::Migration[5.2]
  def change
    add_reference :proposals, :sentiment, foreign_key: true
  end
end
