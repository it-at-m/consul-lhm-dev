class CreateGeozoneProjektJoinTable < ActiveRecord::Migration[5.2]
  def change
    create_join_table :geozones, :projekts do |t|
      # t.index [:geozone_id, :projekt_id]
      t.index [:projekt_id, :geozone_id], unique: true
    end
  end
end
