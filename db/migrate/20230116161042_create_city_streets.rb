class CreateCityStreets < ActiveRecord::Migration[5.2]
  def change
    create_table :city_streets do |t|
      t.string :name
      t.string :plz

      t.timestamps
    end
  end
end
