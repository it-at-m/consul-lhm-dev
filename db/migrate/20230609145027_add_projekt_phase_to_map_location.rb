class AddProjektPhaseToMapLocation < ActiveRecord::Migration[5.2]
  def change
    add_reference :map_locations, :projekt_phase, foreign_key: true
  end
end
