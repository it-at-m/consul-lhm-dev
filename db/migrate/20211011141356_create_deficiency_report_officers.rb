class CreateDeficiencyReportOfficers < ActiveRecord::Migration[5.2]
  def change
    create_table :deficiency_report_officers do |t|
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
