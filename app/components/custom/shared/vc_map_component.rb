class Shared::VCMapComponent < ApplicationComponent
  attr_reader :mappable, :map_location, :parent_class, :editable,
              :process_coordinates, :projekt, :show_admin_shape, :map_style
  delegate :map_location_latitude, :map_location_longitude, :map_location_zoom,
           :map_location_input_id, :projekt_feature?, to: :helpers

  def initialize(
    mappable: nil,
    map_location: nil,
    parent_class:,
    editable: false,
    process_coordinates: nil,
    projekt: nil,
    projekt_phase: nil,
    show_admin_shape: false
  )
    @mappable = mappable
    @map_location = map_location || MapLocation.new
    @parent_class = parent_class
    @editable = editable
    @process_coordinates = process_coordinates || get_process_coordinates
    @projekt = projekt
    @projekt_phase = projekt_phase
    @show_admin_shape = show_admin_shape
  end

  def map_div
    content_tag :div,
                id: "myMapUUIDnew",
                # id: "#{dom_id(map_location)}_#{parent_class}",
                # class: "map_location map",
                data: prepare_map_settings do
      content_tag :span, "Map"
    end
  end

  def show_controls?
    parent_class != "proposals_sidebar"
  end

  private

    def prepare_map_settings
      options = {
        vcmap: "",

        map_center_latitude: map_location_latitude(map_location),
        map_center_longitude: map_location_longitude(map_location),
        map_zoom: map_location_zoom(map_location),

        # admin_editor: false,

        # show_admin_shape: show_admin_shape,
        # admin_shape: admin_shape,

        parent_class: parent_class,
        process_coordinates: process_coordinates,

        latitude_input_selector: "##{map_location_input_id(parent_class, "latitude")}",
        longitude_input_selector: "##{map_location_input_id(parent_class, "longitude")}",
        altitude_input_selector: "##{map_location_input_id(parent_class, "altitude")}",
        zoom_input_selector: "##{map_location_input_id(parent_class, "zoom")}",
        shape_input_selector: "##{map_location_input_id(parent_class, "shape")}",
        default_color: "#00ff00",

        editable: editable
      }


      options
    end

    def get_process_coordinates
      if mappable.present? && mappable.map_location.present?
        [
          mappable.map_location.shape_json_data.presence ||
            mappable.map_location.json_data
        ]
      else
        []
      end
    end

    # def admin_shape
    #   return unless projekt.present?

    #   projekt.map_location.shape_json_data.presence || projekt.map_location.json_data.to_json
    # end
end
