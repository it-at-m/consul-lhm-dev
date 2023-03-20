class CreateRegisteredAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :registered_addresses do |t|
      t.string :city
      t.string :street_name
      t.string :street_number
      t.string :street_number_extension
      t.jsonb :groupings, null: false, default: {}

      t.timestamps
    end

    add_index :registered_addresses, :groupings, using: :gin
  end
end
