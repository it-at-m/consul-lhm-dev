module AdminActions::BudgetWizard::Groups
  extend ActiveSupport::Concern

  include Admin::BudgetGroupsActions

  included do
    before_action :load_groups, only: [:index, :create]
  end

  def index
    @group = @budget.groups.first_or_initialize("name_#{I18n.locale}" => @budget.name)
    authorize!(:read, @group) if @namespace == :projekt_management

    render "admin/budgets_wizard/groups/index"
  end

  private

    def groups_index
      # admin_budgets_wizard_budget_group_headings_path(@budget, @group)
      polymorphic_path([@namespace, :budgets_wizard, @budget, @group, :headings])
    end

    def new_action
      render "admin/budgets_wizard/groups/index"
    end
end
