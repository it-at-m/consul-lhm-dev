class Admin::ModalNotificationsController < Admin::BaseController
  include Translatable

  load_and_authorize_resource

  def index
    @modal_notifications = ModalNotification.order(created_at: :desc).page(params[:page])
  end

  def create
    @modal_notification = ModalNotification.new(modal_notification_params)
    if @modal_notification.save
      redirect_to admin_modal_notifications_path, notice: t("custom.admin.modal_notifications.create.notice")
    else
      render :new
    end
  end

  def update
    if @modal_notification.update(modal_notification_params)
      redirect_to admin_modal_notifications_path, notice: t("custom.admin.modal_notifications.update.notice")
    else
      render :edit
    end
  end

  def destroy
    @modal_notification.destroy!
    redirect_to admin_modal_notifications_path, notice: t("custom.admin.modal_notifications.destroy.notice")
  end

  private

    def modal_notification_params
      params.require(:modal_notification).permit(allowed_params)
    end

    def allowed_params
      [:active_from, :active_to,
       translation_params(ModalNotification)]
    end
end
