module ProjektControllerHelper

  def all_projekts_map_locations(projekts_for_map)
    # ids = projekts_for_map.except(:limit, :offset, :order).pluck(:id).uniq
    ids = projekts_for_map.map(&:id).uniq

    MapLocation.where(projekt_id: ids).map(&:json_data)
  end
end
