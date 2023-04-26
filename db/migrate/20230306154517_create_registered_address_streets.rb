class CreateRegisteredAddressStreets < ActiveRecord::Migration[5.2]
  def change
    create_table :registered_address_streets do |t|
      t.string :name
      t.string :plz

      t.timestamps
    end

    add_index :registered_address_streets, [:name, :plz], unique: true
  end
end
