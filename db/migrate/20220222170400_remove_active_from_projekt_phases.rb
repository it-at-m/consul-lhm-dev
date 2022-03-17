class RemoveActiveFromProjektPhases < ActiveRecord::Migration[5.2]
  def change
    remove_column :projekt_phases, :active
  end
end
