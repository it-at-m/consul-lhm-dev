class AddDescriptionToProjektEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :projekt_events, :description, :text
  end
end
