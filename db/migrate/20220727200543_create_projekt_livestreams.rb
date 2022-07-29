class CreateProjektLivestreams < ActiveRecord::Migration[5.2]
  def change
    create_table :projekt_livestreams do |t|
      t.string :url
      t.string :video_platform
      t.string :title
      t.datetime :starts_at
      t.text :description
      t.references :projekt, index: true
      t.string :external_id
      t.string :preview_image_url
      t.timestamps
    end
  end
end
