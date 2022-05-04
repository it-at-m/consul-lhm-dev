class Pages::Projekts::SidebarMapComponent < ApplicationComponent
  delegate :render_map, :get_projekt_affiliation_name, to: :helpers
  attr_reader :projekt

  def initialize(projekt, default_phase_name)
    @projekt = projekt
    @default_phase_name = default_phase_name
  end

  private
end
