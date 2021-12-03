class AddConcealedToImages < ActiveRecord::Migration[5.2]
  def change
    add_column :images, :concealed, :boolean, default: false
  end
end
