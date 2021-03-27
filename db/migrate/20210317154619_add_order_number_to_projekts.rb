class AddOrderNumberToProjekts < ActiveRecord::Migration[5.1]
  def change
    add_column :projekts, :order_number, :integer
  end
end
