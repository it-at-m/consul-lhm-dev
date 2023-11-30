class AddQuestionBundleToPollQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :poll_questions, :bundle_question, :boolean, default: false
  end
end
