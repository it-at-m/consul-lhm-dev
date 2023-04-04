class Pages::Projekts::BudgetsTabComponent < ApplicationComponent
  delegate :can?, :projekt_feature?, to: :helpers
  attr_reader :budget, :ballot, :current_user, :heading

  def initialize(budget, ballot, current_user)
    @budget = budget
    @ballot = ballot
    @current_user = current_user
    @heading = @budget.headings.first
  end

  private

  def render_map?
    !budget.informing? &&
      projekt_feature?(budget.projekt, 'budgets.show_map') &&
      controller_name != "offline_ballots"
  end

  def phases
    budget.published_phases
  end

  def phase_dom_id(phase)
    "phase-#{phases.index(phase) + 1}-#{phase.name.parameterize}"
  end

  def coordinates
    return unless budget.present?

    if budget.publishing_prices_or_later? && budget.investments.selected.any?
      investments = budget.investments.selected
    else
      investments = budget.investments
    end

    MapLocation.where(investment_id: investments, shape: {}).map(&:json_data)
  end
end
