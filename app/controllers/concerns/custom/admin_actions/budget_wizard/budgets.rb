module AdminActions::BudgetWizard::Budgets
  extend ActiveSupport::Concern

  include Translatable
  include ImageAttributes
  include FeatureFlags

  included do
    feature_flag :budgets

    load_and_authorize_resource
  end

  def new
    render "admin/budgets_wizard/budgets/new"
  end

  def edit
  end

  def create
    @budget.published = false
    params[:mode] == 'single'

    if params[:budget][:projekt_phase_id].blank?
      @budget.valid?
      @budget.errors.add(:projekt_phase_id, :blank)
      render :new
    elsif @budget.save
      redirect_to groups_index, notice: t("admin.budgets.create.notice")
    else
      render :new
    end
  end

  def update
    if @budget.update(budget_params)
      redirect_to groups_index, notice: t("admin.budgets.update.notice")
    else
      render :edit
    end
  end

  private

    def budget_params
      params.require(:budget).permit(allowed_params)
    end

    def allowed_params
      valid_attributes = [:currency_symbol, :voting_style, :projekt_phase_id, administrator_ids: [],
                          valuator_ids: [], image_attributes: image_attributes]

      [*valid_attributes, translation_params(Budget)]
    end

    def groups_index
      admin_budgets_wizard_budget_groups_path(@budget, url_params)
    end
end
