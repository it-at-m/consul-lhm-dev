class AddProjektPhaseToProposals < ActiveRecord::Migration[5.2]
  def change
    add_reference :proposals, :projekt_phase, foreign_key: true
  end
end
