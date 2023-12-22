class AddCustomTextFieldsToProjektPhases < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        ProjektPhase.create_translation_table! phase_tab_name: :string, resource_form_title: :text
      end

      dir.down do
        ProjektPhase.drop_translation_table!
      end
    end
  end
end
