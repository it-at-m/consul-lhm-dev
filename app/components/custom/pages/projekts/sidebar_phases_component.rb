class Pages::Projekts::SidebarPhasesComponent < ApplicationComponent
  delegate :format_date_range, :format_date, :projekt_feature?, :projekt_phase_feature?, to: :helpers
  attr_reader :projekt, :phases, :milestone_phase

  def initialize(projekt)
    @projekt = projekt
    @phases = projekt.projekt_phases.active.sorted
    @milestone_phase = projekt.milestone_phases.first
  end

  def render?
    phases.any?
  end

  private

    def show_cta?
      return true if projekt.budget_phases.any?(&:current?) && projekt.budgets.any?{ |budget| budget.phase.in?(%w[accepting selecting balloting]) }

      phases.any? { |phase| phase.type != "ProjektPhase::BudgetPhase" && phase.current? }
    end
end
