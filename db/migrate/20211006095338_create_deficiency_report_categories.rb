class CreateDeficiencyReportCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :deficiency_report_categories do |t|
      t.string :color
      t.string :icon

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        DeficiencyReport::Category.create_translation_table! name: :string
      end

      dir.down do
        DeficiencyReport::Category.drop_translation_table!
      end
    end
  end
end
