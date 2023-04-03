module MapLocationAttributes
  extend ActiveSupport::Concern

  def map_location_attributes
    [:latitude, :longitude, :zoom, :shape, :pin_color]
  end
end
