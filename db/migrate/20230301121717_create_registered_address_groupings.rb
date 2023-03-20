class CreateRegisteredAddressGroupings < ActiveRecord::Migration[5.2]
  def change
    create_table :registered_address_groupings do |t|
      t.string :key
      t.string :name

      t.timestamps
    end
  end
end
