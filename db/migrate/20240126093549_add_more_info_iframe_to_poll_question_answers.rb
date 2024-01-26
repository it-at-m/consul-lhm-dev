class AddMoreInfoIframeToPollQuestionAnswers < ActiveRecord::Migration[5.2]
  def change
    add_column :poll_question_answers, :more_info_iframe, :string
  end
end
