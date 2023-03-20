class AddRegisteredAddressToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :registered_address, foreign_key: true
  end
end
