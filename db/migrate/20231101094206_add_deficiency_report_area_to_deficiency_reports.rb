class AddDeficiencyReportAreaToDeficiencyReports < ActiveRecord::Migration[5.2]
  def change
    add_reference :deficiency_reports, :deficiency_report_area, foreign_key: true
  end
end
