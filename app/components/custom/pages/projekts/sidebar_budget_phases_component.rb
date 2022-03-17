class Pages::Projekts::SidebarBudgetPhasesComponent < ApplicationComponent
  delegate :format_date_range, to: :helpers
  attr_reader :budget, :phases

  def initialize(budget)
    @budget = budget
    @phases = budget.published_phases
  end

  private
end
