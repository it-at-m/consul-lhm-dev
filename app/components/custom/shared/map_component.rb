class Shared::MapComponent < ApplicationComponent
  attr_reader :mappable, :map_location, :parent_class, :editable,
              :process_coordinates, :projekt
  delegate :map_location_latitude, :map_location_longitude, :map_location_zoom,
           :map_location_input_id, to: :helpers

  def initialize(
    mappable: nil,
    map_location: nil,
    parent_class:,
    editable: false,
    process_coordinates: nil,
    projekt: nil
  )
    @mappable = mappable
    @map_location = map_location || MapLocation.new
    @parent_class = parent_class
    @editable = editable
    @process_coordinates = process_coordinates || get_process_coordinates
    @projekt = projekt
  end

  def map_div
    content_tag :div, "",
                id: "#{dom_id(map_location)}_#{parent_class}",
                class: "map_location map",
                data: prepare_map_settings
  end

  private

    def prepare_map_settings
      options = {
        map: "",

        map_center_latitude: map_location_latitude(map_location),
        map_center_longitude: map_location_longitude(map_location),
        map_zoom: map_location_zoom(map_location),

        admin_editor: false,
        admin_shape: admin_shape,

        parent_class: parent_class,
        process_coordinates: process_coordinates,

        latitude_input_selector: "##{map_location_input_id(parent_class, "latitude")}",
        longitude_input_selector: "##{map_location_input_id(parent_class, "longitude")}",
        zoom_input_selector: "##{map_location_input_id(parent_class, "zoom")}",
        shape_input_selector: "##{map_location_input_id(parent_class, "shape")}",

        editable: editable
      }

      options[:marker_latitude] = map_location.latitude if map_location.latitude.present?
      options[:marker_longitude] = map_location.longitude if map_location.longitude.present?
      options[:map_layers] = map_layers if map_layers.present?
      options
    end

    def get_process_coordinates
      if mappable&.map_location&.shape.present?
        [mappable.map_location.shape]
      elsif mappable&.map_location.present?
        [mappable.map_location.json_data]
      else
        []
      end
    end

    def map_layers
      if projekt.present?
        projekt.map_layers_for_render.to_json
      else
        MapLayer.general.to_json
      end
    end

    def admin_shape
      return unless projekt.present?

      JSON.parse(projekt.map_location.shape).presence&.to_json || projekt.map_location.json_data.to_json
    end
end
