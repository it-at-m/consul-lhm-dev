class CreateDeficiencyReportStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :deficiency_report_statuses do |t|
      t.string :color
      t.string :icon

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        DeficiencyReport::Status.create_translation_table! title: :string, description: :text
      end

      dir.down do
        DeficiencyReport::Status.drop_translation_table!
      end
    end
  end
end
