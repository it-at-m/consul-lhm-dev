class CreateProjektEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :projekt_events do |t|
      t.string :title
      t.string :location
      t.datetime :datetime
      t.string :weblink
      t.integer :projekt_id

      t.timestamps
    end
  end
end
