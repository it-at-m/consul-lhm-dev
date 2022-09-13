class AddSpecialTopProjekts < ActiveRecord::Migration[5.2]
  def change
    add_column :projekts, :special, :boolean, default: false
    add_column :projekts, :special_name, :string, unique: true
  end
end
