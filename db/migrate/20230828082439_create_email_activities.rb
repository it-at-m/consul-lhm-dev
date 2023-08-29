class CreateEmailActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :email_activities do |t|
      t.string :email
      t.references :actionable, polymorphic: true

      t.timestamps
    end

    add_index :email_activities, [:actionable_id, :actionable_type]
  end
end
