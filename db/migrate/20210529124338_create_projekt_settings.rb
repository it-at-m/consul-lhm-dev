class CreateProjektSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :projekt_settings do |t|
      t.references :projekt, foreign_key: true
      t.string :key
      t.string :value

      t.timestamps
    end
  end
end
