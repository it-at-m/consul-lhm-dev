class AddNotifyOfficerAboutNewCommentsToDeficiencyReports < ActiveRecord::Migration[5.2]
  def change
    add_column :deficiency_reports, :notify_officer_about_new_comments, :boolean, default: false
    add_column :deficiency_reports, :notified_officer_about_new_comments_datetime, :datetime
  end
end
