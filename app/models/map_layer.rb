class MapLayer < ApplicationRecord
  belongs_to :projekt, optional: true

  enum protocol: { regular: 0, wms: 1 }

  scope :general, -> { where(projekt_id: nil) }

  def self.ensure_existence_of_base_layer
    return if MapLayer.general.any?

    MapLayer.create(
      name: 'Base',
      provider: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
      attribution: "&copy; <a href=\"http://osm.org/copyright\">OpenStreetMap</a> contributors",
      base: true,
      protocol: "regular"
    )
  end

  def self.protocol_attributes_for_select
    protocols.map do |protocol, _|
      [protocol, I18n.t("activerecord.attributes.map_layer.protocols.#{protocol}")]
    end
  end
end
