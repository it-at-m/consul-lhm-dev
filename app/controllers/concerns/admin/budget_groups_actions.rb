module Admin::BudgetGroupsActions
  extend ActiveSupport::Concern

  included do
    include Translatable
    include FeatureFlags
    feature_flag :budgets

    before_action :load_budget
    before_action :load_group, only: [:edit, :update, :destroy]
    before_action :correct_namespace #custom
  end

  def edit
    render "admin/budgets_wizard/groups/edit"
  end

  def create
    @group = @budget.groups.new(budget_group_params)
    authorize!(:create, @budget) if @namespace.to_s.start_with?("projekt_management")

    if @group.save
      redirect_to groups_index, notice: t("admin.budget_groups.create.notice")
    else
      render new_action
    end
  end

  def update
    authorize!(:create, @budget) if @namespace.to_s.start_with?("projekt_management")

    if @group.update(budget_group_params)
      redirect_to groups_index, notice: t("admin.budget_groups.update.notice")
    else
      render "admin/budgets_wizard/groups/edit"
    end
  end

  def destroy
    authorize!(:create, @budget) if @namespace.to_s.start_with?("projekt_management")

    if @group.headings.any?
      redirect_to groups_index, alert: t("admin.budget_groups.destroy.unable_notice")
    else
      @group.destroy!
      redirect_to groups_index, notice: t("admin.budget_groups.destroy.success_notice")
    end
  end

  private

    def load_budget
      @budget = Budget.find_by_slug_or_id! params[:budget_id]
    end

    def load_groups
      @groups = @budget.groups.order(:id)
    end

    def load_group
      @group = @budget.groups.find_by_slug_or_id! params[:id]
    end

    def budget_group_params
      params.require(:budget_group).permit(allowed_params)
    end

    def allowed_params
      valid_attributes = [:max_votable_headings]

      [*valid_attributes, translation_params(Budget::Group)]
    end

    def correct_namespace
      if params[:controller].include?("budgets_wizard")
        @namespace = (@namespace.to_s + "_" + "budgets_wizard").to_sym
      end
    end
end
