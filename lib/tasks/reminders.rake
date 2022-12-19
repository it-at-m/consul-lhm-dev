namespace :reminders do
  desc "Send defficiency report officers reminders about overdue reports"
  task overdue_deficiency_reports: :environment do
    ApplicationLogger.new.info "Send defficiency report officers reminders about overdue reports"
    DeficiencyReport.send_overdue_reminders
  end
end
