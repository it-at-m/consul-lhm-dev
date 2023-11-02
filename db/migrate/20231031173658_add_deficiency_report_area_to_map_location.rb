class AddDeficiencyReportAreaToMapLocation < ActiveRecord::Migration[5.2]
  def change
    add_reference :map_locations, :deficiency_report_area, foreign_key: true
  end
end
