class AddProjektSelectorHintToProjektPhase < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        ProjektPhase.add_translation_fields! projekt_selector_hint: :text
      end

      dir.down do
        remove_column :projekt_phase_translations, :projekt_selector_hint
      end
    end
  end
end
