class AddGivenOrderToProjektPhases < ActiveRecord::Migration[5.2]
  def change
    add_column :projekt_phases, :given_order, :integer
  end
end
