module Admin::BudgetPhasesActions
  extend ActiveSupport::Concern

  included do
    include Translatable
    include ImageAttributes

    before_action :load_budget
    before_action :load_phase, only: [:edit, :update, :toggle_enabled]
    before_action :correct_namespace #custom
  end

  def edit
    authorize!(:create, @budget) if @namespace.to_s.start_with?("projekt_management")

    render "admin/budgets_wizard/phases/edit"
  end

  def update
    authorize!(:create, @budget) if @namespace.to_s.start_with?("projekt_management")

    if @phase.update(budget_phase_params)
      redirect_to phases_index, notice: t("flash.actions.save_changes.notice")
    else
      render "admin/budgets_wizard/phases/edit"
    end
  end

  def toggle_enabled
    authorize!(:create, @budget) if @namespace.to_s.start_with?("projekt_management")

    @phase.update!(enabled: !@phase.enabled)

    respond_to do |format|
      format.html { redirect_to phases_index, notice: t("flash.actions.save_changes.notice") }
      format.js { render "admin/budgets_wizard/phases/toggle_enabled" }
    end
  end

  private

    def load_budget
      @budget = Budget.find_by_slug_or_id!(params[:budget_id])
    end

    def load_phase
      @phase = @budget.phases.find(params[:id])
    end

    def budget_phase_params
      params.require(:budget_phase).permit(allowed_params)
    end

    def allowed_params
      valid_attributes = [:starts_at, :ends_at, :enabled,
                          image_attributes: image_attributes]

      [*valid_attributes, translation_params(Budget::Phase)]
    end

    def correct_namespace
      if params[:controller].include?("budgets_wizard")
        @namespace = (@namespace.to_s + "_" + "budgets_wizard").to_sym
      end
    end
end
