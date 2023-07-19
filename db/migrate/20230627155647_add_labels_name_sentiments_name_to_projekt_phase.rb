class AddLabelsNameSentimentsNameToProjektPhase < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        ProjektPhase.add_translation_fields! labels_name: :string, sentiments_name: :string
      end

      dir.down do
        remove_column :projekt_phase_translations, :labels_name
        remove_column :projekt_phase_translations, :sentiments_name
      end
    end
  end
end
