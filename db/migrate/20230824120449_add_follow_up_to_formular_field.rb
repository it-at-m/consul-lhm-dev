class AddFollowUpToFormularField < ActiveRecord::Migration[5.2]
  def change
    add_column :formular_fields, :follow_up, :boolean, default: false
  end
end
