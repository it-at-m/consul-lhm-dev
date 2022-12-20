class AddAssignedAtToDeficiencyReports < ActiveRecord::Migration[5.2]
  def change
    add_column :deficiency_reports, :assigned_at, :datetime
  end
end
