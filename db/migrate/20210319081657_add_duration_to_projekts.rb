class AddDurationToProjekts < ActiveRecord::Migration[5.1]
  def change
    add_column :projekts, :total_duration_active,    :boolean
    add_column :projekts, :total_duration_start,     :date
    add_column :projekts, :total_duration_end,       :date
    add_column :projekts, :debate_phase_active,      :boolean
    add_column :projekts, :debate_phase_start,       :date
    add_column :projekts, :debate_phase_end,         :date
    add_column :projekts, :proposal_phase_active,    :boolean
    add_column :projekts, :proposal_phase_start,     :date
    add_column :projekts, :proposal_phase_end,       :date
  end
end
