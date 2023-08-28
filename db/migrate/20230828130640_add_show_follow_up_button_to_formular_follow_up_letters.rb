class AddShowFollowUpButtonToFormularFollowUpLetters < ActiveRecord::Migration[5.2]
  def change
    add_column :formular_follow_up_letters, :show_follow_up_button, :boolean, default: false
  end
end
