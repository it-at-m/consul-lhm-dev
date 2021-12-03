class AddTsvToDeficiencyReports < ActiveRecord::Migration[5.2]
  def change
    add_column :deficiency_reports, :tsv, :tsvector
    add_index :deficiency_reports, :tsv, using: "gin"
  end
end
