class CreateIndividualGroupValues < ActiveRecord::Migration[5.2]
  def change
    create_table :individual_group_values do |t|
      t.string :name
      t.references :individual_group, foreign_key: true

      t.timestamps
    end
  end
end
