class AddNextQuestionIdToPollQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :poll_questions, :next_question_id, :integer
    add_index :poll_questions, :next_question_id
  end
end
