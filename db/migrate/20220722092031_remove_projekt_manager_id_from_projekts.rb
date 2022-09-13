class RemoveProjektManagerIdFromProjekts < ActiveRecord::Migration[5.2]
  def change
    remove_column :projekts, :projekt_manager_id, :integer
  end
end
