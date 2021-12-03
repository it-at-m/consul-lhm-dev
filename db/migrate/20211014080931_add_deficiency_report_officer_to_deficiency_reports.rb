class AddDeficiencyReportOfficerToDeficiencyReports < ActiveRecord::Migration[5.2]
  def change
    add_reference :deficiency_reports, :deficiency_report_officer, foreign_key: true
  end
end
