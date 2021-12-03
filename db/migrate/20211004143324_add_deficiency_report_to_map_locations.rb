class AddDeficiencyReportToMapLocations < ActiveRecord::Migration[5.2]
  def change
    add_reference :map_locations, :deficiency_report, foreign_key: true
  end
end
