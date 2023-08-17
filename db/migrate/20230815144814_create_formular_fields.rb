class CreateFormularFields < ActiveRecord::Migration[5.2]
  def change
    create_table :formular_fields do |t|
      t.string :name
      t.string :description
      t.string :key
      t.string :kind
      t.boolean :required, default: false, null: false
      t.jsonb :options, default: {}, null: false
      t.references :formular, foreign_key: true

      t.index [:name, :formular_id], unique: true
      t.index [:key, :formular_id], unique: true

      t.timestamps
    end
  end
end
