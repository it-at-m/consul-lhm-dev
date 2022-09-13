class CreateProjektManagerAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :projekt_manager_assignments do |t|
      t.references :projekt, foreign_key: true
      t.references :projekt_manager, foreign_key: true

      t.timestamps
    end
  end
end
