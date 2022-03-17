class AddProjektsCountToTags < ActiveRecord::Migration[5.2]
  def change
    add_column :tags, :projekts_count, :integer, default: 0
  end
end
