class RenameNewResourceButtonNameInProjektPhaseTranslations < ActiveRecord::Migration[5.2]
  def change
    if column_exists?(:projekt_phase_translations, :new_resource_button_name)
      rename_column :projekt_phase_translations, :new_resource_button_name, :cta_button_name
    else
      add_column :projekt_phase_translations, :cta_button_name, :string
    end
  end
end
