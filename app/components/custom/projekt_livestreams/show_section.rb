class ProjektLivestreams::ShowSection < ApplicationComponent
  def initialize(current_projekt_livestream:, other_livestreams: nil)
    @current_projekt_livestream = current_projekt_livestream
    @other_livestreams = other_livestreams
  end
end
