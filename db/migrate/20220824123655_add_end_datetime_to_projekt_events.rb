class AddEndDatetimeToProjektEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :projekt_events, :end_datetime, :datetime
  end
end
