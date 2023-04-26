class CreateRegisteredAddressCities < ActiveRecord::Migration[5.2]
  def change
    create_table :registered_address_cities do |t|
      t.string :name

      t.timestamps
    end

    remove_column :registered_addresses, :city, :string
    add_column :registered_addresses, :registered_address_city_id , :integer, foreign_key: true
  end
end
