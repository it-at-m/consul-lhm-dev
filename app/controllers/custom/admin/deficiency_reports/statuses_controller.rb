class Admin::DeficiencyReports::StatusesController < Admin::BaseController
  include Translatable
  load_and_authorize_resource :status, class: "DeficiencyReport::Status", except: :show

  def index
    @statuses = DeficiencyReport::Status.all.order(given_order: :asc)
  end

  def new
  end

  def edit
  end

  def create
    @status = DeficiencyReport::Status.new(status_params)

    if @status.save
      redirect_to admin_deficiency_report_statuses_path
    else
      render :new
    end
  end

  def update
    if @status.update(status_params)
      redirect_to admin_deficiency_report_statuses_path
    else
      render :edit
    end
  end

  def destroy
    if @status.safe_to_destroy?
      @status.destroy!
      redirect_to admin_deficiency_report_statuses_path, notice: t('custom.admin.deficiency_reports.statuses.destroy.destroyed_successfully')
    else
      redirect_to admin_deficiency_report_statuses_path, alert: t('custom.admin.deficiency_reports.statuses.destroy.cannot_be_destroyed')
    end
  end

  def order_statuses
    DeficiencyReport::Status.order_statuses(params[:ordered_list])
    head :ok
  end

  private

  def status_params
    params.require(:deficiency_report_status).permit(:color, :icon, translation_params(DeficiencyReport::Status))
  end
end
