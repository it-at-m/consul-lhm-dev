class AddVotesToDeficiencyReports < ActiveRecord::Migration[5.2]
  def change
    add_column :deficiency_reports, :cached_votes_total, :integer, default: 0
    add_index :deficiency_reports, :cached_votes_total
    add_column :deficiency_reports, :cached_votes_up, :integer, default: 0
    add_index :deficiency_reports, :cached_votes_up
    add_column :deficiency_reports, :cached_votes_down, :integer, default: 0
    add_index :deficiency_reports, :cached_votes_down
    add_column :deficiency_reports, :cached_votes_score, :integer, default: 0
    add_index :deficiency_reports, :cached_votes_score
    add_column :deficiency_reports, :cached_anonymous_votes_total, :integer, default: 0
    add_index :deficiency_reports, :cached_anonymous_votes_total
  end
end
