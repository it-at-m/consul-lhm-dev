class CreateProjektArguments < ActiveRecord::Migration[5.2]
  def change
    create_table :projekt_arguments do |t|
      t.string :name
      t.string :party
      t.boolean :pro
      t.string :position
      t.text :note
      t.integer :projekt_id, index: true
      t.timestamps
    end
  end
end
