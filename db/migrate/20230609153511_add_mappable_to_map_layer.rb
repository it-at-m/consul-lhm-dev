class AddMappableToMapLayer < ActiveRecord::Migration[5.2]
  def change
    add_reference :map_layers, :mappable, polymorphic: true
  end
end
