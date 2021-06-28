class AddPinColorToMapLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :map_locations, :pin_color, :string
  end
end
