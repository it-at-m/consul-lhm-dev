class CreateProjektSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :projekt_subscriptions do |t|
      t.references :projekt, foreign_key: true
      t.references :user, foreign_key: true
      t.boolean :active, default: false

      t.timestamps
    end
  end
end
