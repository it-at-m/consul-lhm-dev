class AddOpenAnswerOpenAnswerTextToPollQuestionAnswer < ActiveRecord::Migration[5.2]
  def change
    add_column :poll_question_answers, :open_answer, :boolean, default: false
    add_column :poll_question_answers, :open_answer_text, :string
  end
end
