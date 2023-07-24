class MapLayer < ApplicationRecord
  belongs_to :mappable, polymorphic: true

  enum protocol: { regular: 0, wms: 1 }

  def self.general
    special_projekt = Projekt.find_by(special: true)
    where(mappable: special_projekt).or(where(mappable: nil))
  end

  def self.protocol_attributes_for_select
    protocols.map do |protocol, _|
      [protocol, I18n.t("activerecord.attributes.map_layer.protocols.#{protocol}")]
    end
  end
end
