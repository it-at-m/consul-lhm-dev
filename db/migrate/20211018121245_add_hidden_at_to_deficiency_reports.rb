class AddHiddenAtToDeficiencyReports < ActiveRecord::Migration[5.2]
  def change
    add_column :deficiency_reports, :hidden_at, :datetime
    add_index :deficiency_reports, :hidden_at
  end
end
