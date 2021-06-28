namespace :projekt_settings do
  desc "Ensure existence of projekt settings"
  task ensure_existence: :environment do
    ApplicationLogger.new.info "Making sure projekts have "
    ProjektSetting.ensure_existence
  end

  desc "Remove obsolete tasks"
  task destroy_obsolete: :environment do
    ApplicationLogger.new.info "Removing obsolete settings"
    ProjektSetting.destroy_obsolete
  end
end
