class AddColorIconToProjekts < ActiveRecord::Migration[5.2]
  def change
    add_column :projekts, :color, :string
    add_column :projekts, :icon, :string
  end
end
