class Pages::Projekts::SidebarPhasesComponent < ApplicationComponent
  delegate :format_date_range, :format_date, :projekt_feature?, to: :helpers
  attr_reader :projekt, :phases, :milestone_phase

  def initialize(projekt)
    @projekt = projekt

    @phases = projekt.projekt_phases.regular_phases.sort do |a, b|
      a.default_order <=> b.default_order
    end.each do |x|
      x.start_date = Time.zone.today if x.start_date.nil?
    end.sort_by(&:start_date)

    @milestone_phase = projekt.milestone_phase
  end

  private

    def phase_title(phase)
      phase.phase_tab_name.presence || t("custom.projekts.page.tabs.#{phase.resources_name}")
    end

    def show_cta?
      return true if projekt.budget.present? && projekt.budget_phase.current? && projekt.budget.phase.in?(%w[accepting selecting balloting])

      phases.any? { |phase| phase.type != "ProjektPhase::BudgetPhase" && phase.current? }
    end
end
