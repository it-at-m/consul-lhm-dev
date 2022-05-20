namespace :map_layers do
  desc "Ensure existence of base map layer"
  task ensure_existence_of_base_layer: :environment do
    ApplicationLogger.new.info "Ensuring existence of map base layer"
    MapLayer.ensure_existence_of_base_layer
  end
end
