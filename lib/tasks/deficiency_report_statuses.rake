namespace :deficiency_report_statuses do
  desc "Add default statuses"
  task add_default_statuses: :environment do
    ApplicationLogger.new.info "Adding default deficiency report statuses"
    DeficiencyReport::Status.create_default_objects
  end
end
