class CreateMapLayers < ActiveRecord::Migration[5.2]
  def change
    create_table :map_layers do |t|
      t.string :name
      t.string :provider
      t.string :attribution
      t.string :protocol
      t.string :layer_names
      t.string :format
      t.string :transparent
      t.boolean :base
      t.references :projekt, foreign_key: true

      t.timestamps
    end
  end
end
