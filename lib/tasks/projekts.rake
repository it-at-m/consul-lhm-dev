namespace :projekts do
  desc "Ensure existence of map locations"
  task ensure_map_existence: :environment do
    ApplicationLogger.new.info "Making sure projekts have maps"
    Projekt.ensure_map_existence
  end
end
