class RenameNewResourceButtonNameInProjektPhaseTranslations < ActiveRecord::Migration[5.2]
  def change
    rename_column :projekt_phase_translations, :new_resource_button_name, :cta_button_name
  end
end
