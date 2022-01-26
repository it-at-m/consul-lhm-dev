class AddGivenOrderToDeficiencyReportStatuses < ActiveRecord::Migration[5.2]
  def change
    add_column :deficiency_report_statuses, :given_order, :integer
  end
end
