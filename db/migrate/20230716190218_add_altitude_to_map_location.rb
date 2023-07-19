class AddAltitudeToMapLocation < ActiveRecord::Migration[5.2]
  def change
    add_column :map_locations, :altitude, :float unless column_exists? :map_locations, :altitude
  end
end
