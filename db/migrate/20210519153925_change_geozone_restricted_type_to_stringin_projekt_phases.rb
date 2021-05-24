class ChangeGeozoneRestrictedTypeToStringinProjektPhases < ActiveRecord::Migration[5.2]
  def change
    change_column :projekt_phases, :geozone_restricted, :string
  end
end
