class AddShowDatesInFrontEndToProjekts < ActiveRecord::Migration[5.2]
  def change
    add_column :projekts, :show_start_date_in_frontend, :boolean, default: true
    add_column :projekts, :show_end_date_in_frontend, :boolean, default: true
  end
end
