class AddHotScoreToDeficiencyReports < ActiveRecord::Migration[5.2]
  def change
    add_column :deficiency_reports, :hot_score, :bigint, default: 0
    add_index :deficiency_reports, :hot_score
  end
end
