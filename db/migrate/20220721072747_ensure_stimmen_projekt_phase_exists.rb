class EnsureStimmenProjektPhaseExists < ActiveRecord::Migration[5.2]
  def up
    Projekt.ensure_projekt_phases
  end
end
