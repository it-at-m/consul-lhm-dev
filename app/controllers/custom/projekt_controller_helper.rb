module ProjektControllerHelper
  def all_projekts_map_locations(projekts_for_map)
    # ids = projekts_for_map.except(:limit, :offset, :order).pluck(:id).uniq
    ids = projekts_for_map.map(&:id).uniq

    MapLocation.where(projekt_id: ids).map do |map_location|
      map_location.shape_json_data.presence || map_location.json_data
    end
  end
end
