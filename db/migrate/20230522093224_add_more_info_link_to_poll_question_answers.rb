class AddMoreInfoLinkToPollQuestionAnswers < ActiveRecord::Migration[5.2]
  def change
    add_column :poll_question_answers, :more_info_link, :string
  end
end
