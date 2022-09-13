class AddDescriptionToPollQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :poll_question_translations, :description, :text
  end
end
