class AddActiveToProjektPhases < ActiveRecord::Migration[5.2]
  def change
    add_column :projekt_phases, :active, :boolean
    add_column :projekt_phases, :info_active, :boolean
  end
end
