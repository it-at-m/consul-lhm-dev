class CreateProjektLabelings < ActiveRecord::Migration[5.2]
  def change
    create_table :projekt_labelings do |t|
      t.references :projekt_label, foreign_key: true
      t.references :labelable, polymorphic: true

      t.timestamps
    end
  end
end
