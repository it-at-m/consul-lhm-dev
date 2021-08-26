class AddShowImagesToPollQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :poll_questions, :show_images, :boolean, default: :false
  end
end
