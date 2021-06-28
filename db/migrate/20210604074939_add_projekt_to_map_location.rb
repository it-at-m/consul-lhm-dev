class AddProjektToMapLocation < ActiveRecord::Migration[5.2]
  def change
    add_reference :map_locations, :projekt, foreign_key: true
  end
end
