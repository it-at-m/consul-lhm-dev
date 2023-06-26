namespace :projekt_phase_settings do
  desc "Add new projekt phase settings"
  task add_new_settings: :environment do
    ApplicationLogger.new.info "Adding new projekt phase settings"
    ProjektPhaseSetting.add_new_settings
  end

  desc "Remove obsolete projekt phase settings"
  task destroy_obsolete: :environment do
    ApplicationLogger.new.info "Removing obsolete projekt phase settings"
    ProjektPhaseSetting.destroy_obsolete
  end
end
