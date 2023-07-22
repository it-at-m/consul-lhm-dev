module ProjektControllerHelper
  def all_projekts_map_locations(projekt_ids)
    MapLocation.where(projekt_id: projekt_ids, show_admin_shape: true).map do |map_location|
      map_location.shape_json_data.presence || map_location.json_data
    end
  end
end
