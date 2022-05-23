class MapLayer < ApplicationRecord
  belongs_to :projekt, optional: true

  enum protocol: { regular: 0, wms: 1 }

  scope :general, -> { where(projekt_id: nil) }

  def self.protocol_attributes_for_select
    protocols.map do |protocol, _|
      [protocol, I18n.t("activerecord.attributes.map_layer.protocols.#{protocol}")]
    end
  end
end
