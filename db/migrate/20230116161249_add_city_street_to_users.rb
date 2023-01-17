class AddCityStreetToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :city_street, foreign_key: true
  end
end
