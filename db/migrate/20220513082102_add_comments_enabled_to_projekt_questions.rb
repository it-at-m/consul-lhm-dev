class AddCommentsEnabledToProjektQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :projekt_questions, :comments_enabled, :boolean, default: true
  end
end
