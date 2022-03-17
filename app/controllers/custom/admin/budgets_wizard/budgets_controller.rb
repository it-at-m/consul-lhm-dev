require_dependency Rails.root.join("app", "controllers", "admin", "budgets_wizard", "budgets_controller").to_s

class Admin::BudgetsWizard::BudgetsController < Admin::BudgetsWizard::BaseController

  def create
    @budget.published = false

    if params[:mode] == 'single' && params[:budget][:projekt_id].blank?
      @budget.valid?
      @budget.errors.add(:projekt_id, :blank)
      render :new
    elsif @budget.save
      redirect_to groups_index, notice: t("admin.budgets.create.notice")
    else
      render :new
    end
  end

  private

    def allowed_params
      valid_attributes = [:currency_symbol, :voting_style, :projekt_id, administrator_ids: [],
                          valuator_ids: [], image_attributes: image_attributes]

      valid_attributes + [translation_params(Budget)]
    end
end
