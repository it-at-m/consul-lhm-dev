class ReplaceStreetNameWithReferenceInRegisteredAddresses < ActiveRecord::Migration[5.2]
  def change
    remove_column :registered_addresses, :street_name, :string
    add_reference :registered_addresses, :registered_address_street, foreign_key: true
  end
end
