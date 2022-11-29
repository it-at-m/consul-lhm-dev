class AddVerificationRestrictedToProjektPhases < ActiveRecord::Migration[5.2]
  def change
    add_column :projekt_phases, :verification_restricted, :boolean, default: false
  end
end
