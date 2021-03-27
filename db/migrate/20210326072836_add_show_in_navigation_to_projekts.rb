class AddShowInNavigationToProjekts < ActiveRecord::Migration[5.1]
  def change
    add_column :projekts, :show_in_navigation, :boolean
  end
end
