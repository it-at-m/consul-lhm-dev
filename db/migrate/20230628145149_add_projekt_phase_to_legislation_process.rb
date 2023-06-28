class AddProjektPhaseToLegislationProcess < ActiveRecord::Migration[5.2]
  def change
    add_reference :legislation_processes, :projekt_phase, foreign_key: true
  end
end
