class ChangeColumnsInMapLayer < ActiveRecord::Migration[5.2]
  def change
    remove_column :map_layers, :transparent, :string
    add_column    :map_layers, :transparent, :boolean, default: false
    remove_column :map_layers, :protocol, :string
    add_column    :map_layers, :protocol, :integer, default: 0
    remove_column :map_layers, :format, :string
  end
end
