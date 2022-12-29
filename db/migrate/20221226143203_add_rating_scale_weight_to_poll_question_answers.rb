class AddRatingScaleWeightToPollQuestionAnswers < ActiveRecord::Migration[5.2]
  def change
    add_column :poll_question_answers, :rating_scale_weight, :integer, default: nil
  end
end
