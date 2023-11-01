class CreateDeficiencyReportAreas < ActiveRecord::Migration[5.2]
  def change
    create_table :deficiency_report_areas do |t|
      t.string :name

      t.timestamps
    end
  end
end
