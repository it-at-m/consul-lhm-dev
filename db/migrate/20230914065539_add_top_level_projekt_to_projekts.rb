class AddTopLevelProjektToProjekts < ActiveRecord::Migration[5.2]
  def change
    add_column :projekts, :top_level_projekt_id, :integer, index: true
  end
end
