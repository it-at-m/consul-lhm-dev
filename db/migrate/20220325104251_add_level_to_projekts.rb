class AddLevelToProjekts < ActiveRecord::Migration[5.2]
  def change
    add_column :projekts, :level, :integer, default: 1
  end
end
