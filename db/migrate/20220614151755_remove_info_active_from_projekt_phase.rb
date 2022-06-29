class RemoveInfoActiveFromProjektPhase < ActiveRecord::Migration[5.2]
  def change
    remove_column :projekt_phases, :info_active, :boolean
  end
end
