class CreateDeficiencyReports < ActiveRecord::Migration[5.2]
  def change
    create_table :deficiency_reports do |t|
      t.integer :author_id
      t.integer :comments_count, default: 0
      t.string  :video_url
      t.boolean :official_answer_approved, default: false
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        DeficiencyReport.create_translation_table! title: :string, description: :text, summary: :text, official_answer: :text
      end

      dir.down do
        DeficiencyReport.drop_translation_table!
      end
    end
  end
end
