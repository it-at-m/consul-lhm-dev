class CreateAgeRestrictions < ActiveRecord::Migration[5.2]
  def change
    create_table :age_restrictions do |t|
      t.integer :order
      t.integer :min_age
      t.integer :max_age

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        AgeRestriction.create_translation_table! name: :string
      end

      dir.down do
        AgeRestriction.drop_translation_table!
      end
    end
  end
end
