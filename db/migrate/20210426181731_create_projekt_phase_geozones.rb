class CreateProjektPhaseGeozones < ActiveRecord::Migration[5.1]
  def change
    create_table :projekt_phase_geozones do |t|
      t.references :projekt_phase, foreign_key: true
      t.references :geozone, foreign_key: true

      t.timestamps
    end
  end
end
