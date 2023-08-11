require_dependency Rails.root.join("app", "helpers", "map_locations_helper").to_s

module MapLocationsHelper
  def map_location_available?(resource)
    return false unless resource.respond_to?(:map_location)

    if resource.respond_to?(:projekt_phase)
      map_location = resource.map_location || resource.projekt_phase.map_location_with_admin_shape
    else
      map_location = resource.map_location
    end

    map_location.present? && map_location.available?
  end

  def render_map(map_location, parent_class, editable, _remove_marker_label, process_coordinates = [], map_layers = nil)
    map_location = MapLocation.new if map_location.nil?
    map = content_tag :div, "",
                      id: "#{dom_id(map_location)}_#{parent_class}",
                      class: "map_location map",
                      data: prepare_map_settings(map_location, editable, parent_class, process_coordinates, map_layers)
    map
  end

  private

    def prepare_map_settings(map_location, editable, parent_class, process_coordinates, map_layers)
      options = {
      parent_class: parent_class,
        map: "",
        map_center_latitude: map_location_latitude(map_location),
        map_center_longitude: map_location_longitude(map_location),
        map_zoom: map_location_zoom(map_location),
        marker_editable: editable,
        latitude_input_selector: "##{map_location_input_id(parent_class, "latitude")}",
        longitude_input_selector: "##{map_location_input_id(parent_class, "longitude")}",
        zoom_input_selector: "##{map_location_input_id(parent_class, "zoom")}",
        marker_process_coordinates: process_coordinates
      }
      options[:marker_latitude] = map_location.latitude if map_location.latitude.present?
      options[:marker_longitude] = map_location.longitude if map_location.longitude.present?
      options[:map_layers] = map_layers if map_layers.present?
      options
    end
end
