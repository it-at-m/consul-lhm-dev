class CreateProjektManagers < ActiveRecord::Migration[5.2]
  def change
    create_table :projekt_managers do |t|
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
