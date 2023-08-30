class CreateFormulars < ActiveRecord::Migration[5.2]
  def change
    create_table :formulars do |t|
      t.references :projekt_phase, foreign_key: true

      t.timestamps
    end
  end
end
