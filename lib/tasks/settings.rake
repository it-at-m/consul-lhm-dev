namespace :settings do
  desc "Add new settings"
  task add_new_settings: :environment do
    ApplicationLogger.new.info "Adding new settings"
    Setting.add_new_settings
  end

  desc "Remove obsolete tasks"
  task destroy_obsolete: :environment do
    ApplicationLogger.new.info "Removing obsolete settings"
    Setting.destroy_obsolete
  end
end
