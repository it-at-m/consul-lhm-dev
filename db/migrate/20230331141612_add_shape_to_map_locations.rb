class AddShapeToMapLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :map_locations, :shape, :jsonb, null: false, default: {}
    add_index :map_locations, :shape, using: :gin
  end
end
