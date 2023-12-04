module AdminActions::BudgetWizard::Budgets
  extend ActiveSupport::Concern

  include Translatable
  include ImageAttributes
  include FeatureFlags

  included do
    feature_flag :budgets

    load_and_authorize_resource except: [:new, :create]
    skip_authorization_check only: :new
  end

  def new
    @budget = Budget.new
    render "admin/budgets_wizard/budgets/new"
  end

  def edit
  end

  def create
    @budget = Budget.new(budget_params)
    authorize! :create, @budget


    @budget.published = false
    params[:mode] = "single"

    if params[:budget][:projekt_phase_id].blank?
      @budget.valid?
      @budget.errors.add(:projekt_phase_id, :blank)
      render "admin/budgets_wizard/budgets/new"
    elsif @budget.save
      redirect_to groups_index, notice: t("admin.budgets.create.notice")
    else
      render "admin/budgets_wizard/budgets/new"
    end
  end

  def update
    if @budget.update(budget_params)
      redirect_to groups_index, notice: t("admin.budgets.update.notice")
    else
      render "admin/budgets_wizard/budgets/edit"
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
      polymorphic_path([@namespace, :budgets_wizard, @budget, :groups])
    end
end
