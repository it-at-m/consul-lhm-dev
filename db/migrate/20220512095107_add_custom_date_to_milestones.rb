class AddCustomDateToMilestones < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        Milestone.add_translation_fields! custom_date: :string
      end

      dir.down do
        remove_column :milestone_translations, :custom_date
      end
    end
  end
end
