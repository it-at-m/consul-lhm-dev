class EnsureNewProjektPhases2 < ActiveRecord::Migration[5.2]
  def change
    Projekt.ensure_projekt_phases
  end
end
