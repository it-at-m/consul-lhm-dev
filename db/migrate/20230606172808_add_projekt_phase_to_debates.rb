class AddProjektPhaseToDebates < ActiveRecord::Migration[5.2]
  def change
    add_reference :debates, :projekt_phase, foreign_key: true
  end
end
