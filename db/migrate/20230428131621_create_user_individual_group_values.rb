class CreateUserIndividualGroupValues < ActiveRecord::Migration[5.2]
  def change
    create_table :user_individual_group_values do |t|
      t.references :user, foreign_key: true
      t.references :individual_group_value, foreign_key: true

      t.timestamps
    end
  end
end
