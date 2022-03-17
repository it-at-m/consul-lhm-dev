class AddDescriptionToProjekts < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        Projekt.create_translation_table! description: :text
      end

      dir.down do
        Projekt.drop_translation_table!
      end
    end
  end
end
