module AdminActions::BudgetWizard::Headings
  extend ActiveSupport::Concern

  include Admin::BudgetHeadingsActions

  included do
    before_action :load_headings, only: [:index, :create]
  end

  def index
    @heading = @group.headings.first_or_initialize
    authorize!(:create, @budget) if @namespace.to_s.start_with?("projekt_management")

    render "admin/budgets_wizard/headings/index"
  end

  private

    def headings_index
      # admin_budgets_wizard_budget_budget_phases_path(@budget, url_params)
      polymorphic_path([@namespace, @heading.group.budget, :budget_phases])
    end

    def load_headings
      @headings = @group.headings.order(:id)
    end

    def new_action
      "admin/budgets_wizard/headings/index"
    end
end
