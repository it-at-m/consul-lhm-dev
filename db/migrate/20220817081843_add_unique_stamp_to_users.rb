class AddUniqueStampToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :unique_stamp, :string
  end
end
