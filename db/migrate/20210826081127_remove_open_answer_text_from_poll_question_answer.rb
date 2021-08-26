class RemoveOpenAnswerTextFromPollQuestionAnswer < ActiveRecord::Migration[5.2]
  def change
    remove_column :poll_question_answers, :open_answer_text, :string
  end
end
