class AddAnswerWeightToPollAnswers < ActiveRecord::Migration[5.2]
  def change
    add_column :poll_answers, :answer_weight, :integer, default: 1
    remove_column :poll_question_answers, :rating_scale_weight, :integer
  end
end
