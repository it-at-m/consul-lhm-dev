class AddRegisteredAddressStreetToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :registered_address_street, foreign_key: true
  end
end
