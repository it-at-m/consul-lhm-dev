class Pages::Projekts::BudgetsSubnavComponent < ApplicationComponent
  delegate :current_user, :can?, to: :helpers
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  private

  def budget_subnav_items_for(budget)
    {
      results:    t("budgets.results.link"),
      stats:      t("stats.budgets.link")
    }.select { |section, _| can?(:"read_#{section}", budget) }.map do |section, text|
      {
        text: text,
        url:  url_for(controller: 'pages', action: 'budget_phase_footer_tab', section: section),
        active: params[:section] == section.to_s
      }
    end
  end
end
