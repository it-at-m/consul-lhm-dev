class RemoveProjektPhaseFieldsFromProjekts < ActiveRecord::Migration[5.1]
  def change
    remove_column :projekts, :debate_phase_active,    :boolean
    remove_column :projekts, :debate_phase_start,     :date
    remove_column :projekts, :debate_phase_end,       :date
    remove_column :projekts, :proposal_phase_active,  :boolean
    remove_column :projekts, :proposal_phase_start,   :date
    remove_column :projekts, :proposal_phase_end,     :date
  end
end
