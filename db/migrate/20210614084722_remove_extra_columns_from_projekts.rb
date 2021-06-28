class RemoveExtraColumnsFromProjekts < ActiveRecord::Migration[5.2]
  def change
    remove_column :projekts, :total_duration_active
    remove_column :projekts, :show_in_navigation
  end
end
