class AddPermissionsToProjektManagerAssignment < ActiveRecord::Migration[5.2]
  def change
    add_column :projekt_manager_assignments, :permissions, :text, array: true, default: []
  end
end
