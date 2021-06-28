class CreateProjektNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :projekt_notifications do |t|
      t.references :projekt, foreign_key: true
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
