class AddNextPollQuestionIdToPollQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :poll_question_answers, :next_question_id, :integer
  end
end
