class Admin::DeficiencyReports::CategoriesController < Admin::BaseController
  include Translatable
  load_and_authorize_resource :category, class: "DeficiencyReport::Category", except: :show

  def index
    @categories = DeficiencyReport::Category.all.order(id: :asc)
  end

  def new
  end

  def edit
  end

  def create
    @category = DeficiencyReport::Category.new(category_params)

    if @category.save
      redirect_to admin_deficiency_report_categories_path
    else
      render :new
    end
  end

  def update
    if @category.update(category_params)
      redirect_to admin_deficiency_report_categories_path
    else
      render :edit
    end
  end

  def destroy
    if @category.safe_to_destroy?
      @category.destroy!
      redirect_to admin_deficiency_report_categories_path, notice: t('custom.admin.deficiency_reports.categories.destroy.destroyed_successfully')
    else
      redirect_to admin_deficiency_report_categories_path, alert: t('custom.admin.deficiency_reports.categories.destroy.cannot_be_destroyed')
    end
  end

  private

  def category_params
    params.require(:deficiency_report_category).permit(:color, :icon, translation_params(DeficiencyReport::Category))
  end
end
