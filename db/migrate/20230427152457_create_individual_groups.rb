class CreateIndividualGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :individual_groups do |t|
      t.string :name
      t.integer :kind, default: 0
      t.boolean :visible, default: false

      t.timestamps
    end
  end
end
