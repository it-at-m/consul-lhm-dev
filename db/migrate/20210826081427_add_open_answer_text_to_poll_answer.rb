class AddOpenAnswerTextToPollAnswer < ActiveRecord::Migration[5.2]
  def change
    add_column :poll_answers, :open_answer_text, :string
  end
end
