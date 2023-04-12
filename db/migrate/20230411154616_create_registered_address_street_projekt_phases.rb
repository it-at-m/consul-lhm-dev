class CreateRegisteredAddressStreetProjektPhases < ActiveRecord::Migration[5.2]
  def change
    create_table :registered_address_street_projekt_phases do |t|
      t.references :registered_address_street,
        foreign_key: true,
        index: { name: "index_ras_projekt_phases_on_ras_id" }
      t.references :projekt_phase,
        foreign_key: true,
        index: { name: "index_ras_projekt_phases_on_projekt_phase_id" }

      t.timestamps
    end
  end
end
