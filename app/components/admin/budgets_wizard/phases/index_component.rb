class Admin::BudgetsWizard::Phases::IndexComponent < Admin::BudgetsWizard::BaseComponent
  include Header
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  def title
    t("admin.budget_phases.index.title", budget: budget.name)
  end

  private

    def back_link_path
      # admin_budgets_wizard_budget_group_headings_path(budget, budget.groups.first, url_params)
      polymorphic_path([namespace, :budgets_wizard, budget, budget.groups.first, :headings])
    end

    def back_link_text
      # t("admin.budgets_wizard.phases.#{budget_mode}.back")
      t("admin.budgets_wizard.phases.single.back")
    end
end
