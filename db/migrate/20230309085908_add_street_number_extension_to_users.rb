class AddStreetNumberExtensionToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :street_number_extension, :string
  end
end
