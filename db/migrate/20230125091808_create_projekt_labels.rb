class CreateProjektLabels < ActiveRecord::Migration[5.2]
  def change
    create_table :projekt_labels do |t|
      t.string :color
      t.string :icon
      t.references :projekt, foreign_key: true

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        ProjektLabel.create_translation_table! name: :string
      end

      dir.down do
        ProjektLabel.drop_translation_table!
      end
    end
  end
end
