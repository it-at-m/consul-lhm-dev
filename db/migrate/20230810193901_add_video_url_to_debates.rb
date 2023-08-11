class AddVideoUrlToDebates < ActiveRecord::Migration[5.2]
  def change
    add_column :debates, :video_url, :string
  end
end
