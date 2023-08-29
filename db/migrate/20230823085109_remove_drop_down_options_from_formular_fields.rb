class RemoveDropDownOptionsFromFormularFields < ActiveRecord::Migration[5.2]
  def change
    remove_column :formular_fields, :drop_down_options, :string
  end
end
