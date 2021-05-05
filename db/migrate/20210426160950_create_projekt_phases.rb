class CreateProjektPhases < ActiveRecord::Migration[5.1]
  def change
    create_table :projekt_phases do |t|
      t.string :type
      t.date :start_date
      t.date :end_date
      t.boolean :active
      t.boolean :geozone_restricted
      t.references :projekt, foreign_key: true

      t.timestamps
    end
  end
end
