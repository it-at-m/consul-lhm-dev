namespace :reminders do
  desc "Send defficiency report officers reminders about overdue reports assigned to them"
  task overdue_deficiency_reports: :environment do
    ApplicationLogger.new.info "Sending defficiency report officers reminders about overdue reports"
    NotificationServices::OverdueDeficiencyReportsReminder.new.call
  end

  desc "Send admins reminders about deficiency reports not assigned to any officers"
  task not_assigned_deficiency_reports: :environment do
    ApplicationLogger.new.info "Sending admins reminders about not assigned defficiency reports"
    NotificationServices::NotAssignedDeficiencyReportsReminder.new.call
  end
end
