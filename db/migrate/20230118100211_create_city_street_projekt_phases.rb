class CreateCityStreetProjektPhases < ActiveRecord::Migration[5.2]
  def change
    create_table :city_street_projekt_phases do |t|
      t.references :city_street, foreign_key: true
      t.references :projekt_phase, foreign_key: true

      t.timestamps
    end
  end
end
