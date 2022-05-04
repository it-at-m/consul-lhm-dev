class Pages::Projekts::SidebarPhasesComponent < ApplicationComponent
  delegate :format_date_range, :format_date, :projekt_feature?, to: :helpers
  attr_reader :projekt, :phases, :milestone_phase

  def initialize(projekt)
    @projekt = projekt
    @phases = projekt.regular_projekt_phases.sort{ |a, b| a.default_order <=> b.default_order }.each{ |x| x.start_date = Date.today if x.start_date.nil? }.sort_by{ |a| a.start_date }
    @milestone_phase = projekt.milestone_phase
  end

  private

  def phase_name(phase, part=nil)
    return t("custom.projekts.phase_name.#{phase.name}_details.#{part}") if part
    t("custom.projekts.phase_name.#{phase.name}")
  end
end
