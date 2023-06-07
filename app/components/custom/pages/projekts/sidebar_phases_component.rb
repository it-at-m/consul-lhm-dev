class Pages::Projekts::SidebarPhasesComponent < ApplicationComponent
  delegate :format_date_range, :format_date, :projekt_feature?, to: :helpers
  attr_reader :projekt, :phases, :milestone_phase

  def initialize(projekt)
    @projekt = projekt
    @phases = projekt.projekt_phases.sorted
    @milestone_phase = projekt.milestone_phase
  end

  private

    def show_cta?
      return true if projekt.budget.present? && projekt.budget_phase.current? && projekt.budget.phase.in?(%w[accepting selecting balloting])

      phases.any? { |phase| phase.type != "ProjektPhase::BudgetPhase" && phase.current? }
    end
end
