class Shared::MapComponent < ApplicationComponent
  attr_reader :mappable, :map_location, :parent_class, :editable,
              :process_coordinates, :projekt, :show_admin_shape
  delegate :map_location_latitude, :map_location_longitude, :map_location_zoom,
           :map_location_input_id, :projekt_feature?, to: :helpers

  def initialize(
    mappable: nil,
    map_location: nil,
    parent_class:,
    editable: false,
    process_coordinates: nil,
    projekt: nil,
    show_admin_shape: false
  )
    @mappable = mappable
    @map_location = map_location || MapLocation.new
    @parent_class = parent_class
    @editable = editable
    @process_coordinates = process_coordinates || get_process_coordinates
    @projekt = projekt
    @show_admin_shape = show_admin_shape
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

        show_admin_shape: show_admin_shape,
        admin_shape: admin_shape,

        parent_class: parent_class,
        process_coordinates: process_coordinates,

        latitude_input_selector: "##{map_location_input_id(parent_class, "latitude")}",
        longitude_input_selector: "##{map_location_input_id(parent_class, "longitude")}",
        zoom_input_selector: "##{map_location_input_id(parent_class, "zoom")}",
        shape_input_selector: "##{map_location_input_id(parent_class, "shape")}",

        editable: editable,
        enable_geoman_controls: enable_geoman_controls?
      }

      options[:map_layers] = map_layers if map_layers.present?
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

    def map_layers
      if projekt.present?
        projekt.map_layers_for_render.to_json
      else
        MapLayer.general.to_json
      end
    end

    def admin_shape
      return unless projekt.present?

      projekt.map_location.shape_json_data.presence || projekt.map_location.json_data.to_json
    end

    def enable_geoman_controls?
      return false unless editable

      if mappable.is_a? DeficiencyReport
        Setting["deficiency_reports.enable_geoman_controls_in_maps"].present?

      elsif projekt.present? && parent_class == "proposal"
        projekt_feature?(projekt, "proposals.enable_geoman_controls_in_maps")

      elsif projekt.present? && parent_class == "budget_investment"
        projekt_feature?(projekt, "budgets.enable_geoman_controls_in_maps")

      else
        false
      end
    end
end
