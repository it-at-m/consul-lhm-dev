class AddOpacityToMapLayers < ActiveRecord::Migration[5.2]
  def change
    add_column :map_layers, :opacity, :decimal, precision: 2, scale: 1, default: 1.0
  end
end
