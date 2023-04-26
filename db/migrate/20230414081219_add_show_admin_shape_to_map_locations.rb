class AddShowAdminShapeToMapLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :map_locations, :show_admin_shape, :boolean, default: false
  end
end
