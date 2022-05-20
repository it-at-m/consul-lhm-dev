class AddShowByDeaultToMapLayer < ActiveRecord::Migration[5.2]
  def change
    add_column :map_layers, :show_by_default, :boolean, default: false
  end
end
