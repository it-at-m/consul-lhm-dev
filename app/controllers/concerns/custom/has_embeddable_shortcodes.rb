module HasEmbeddableShortcodes
  extend ActiveSupport::Concern

  SUPPORTED_SHORTCODES = %w[projekt_map].freeze

  def process_shortcodes_for(obj:, attr:, **vars)
    text = obj.send(attr)

    text.scan(/{{(.*?)}}/) do |shortcode|
      return unless SUPPORTED_SHORTCODES.include?(shortcode.first)

      text = send("replace_#{shortcode.first}", text, **vars)
    end

    text
  end

  private

    def replace_projekt_map(text, **vars)
      return unless vars[:projekt].present?

      projekt = vars[:projekt]

      replacement = helpers.content_tag(:div, style: "margin-top:1rem;margin-bottom:1rem;") do
        if projekt.vc_map_enabled?
          render_to_string Shared::VCMapComponent.new(
            map_location: projekt.map_location,
            parent_class: "shortcode",
            projekt: projekt,
            show_admin_shape: projekt.map_location.show_admin_shape?
          )
        else
          render_to_string Shared::MapComponent.new(
            map_location: projekt.map_location,
            parent_class: "shortcode",
            projekt: projekt,
            show_admin_shape: projekt.map_location.show_admin_shape?
          )
        end
      end

      text.gsub("{{projekt_map}}", replacement)
    end
end
