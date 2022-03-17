class Pages::Projekts::SidebarMapComponent < ApplicationComponent
  delegate :render_map, :get_projekt_affiliation_name, to: :helpers
  attr_reader :projekt

  def initialize(projekt)
    @projekt = projekt
  end

  private
end
