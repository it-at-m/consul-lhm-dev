class Admin::ProjektNotificationsController < Admin::BaseController
  before_action :set_projekt, except: :destroy

  def create
    @projekt_notification = ProjektNotification.new(projekt_notification_params)
    @projekt_notification.projekt = @projekt
    @projekt_notification.save
    redirect_to request_referer, notice: t("admin.settings.flash.updated")
  end

  def update
    @projekt_notification = ProjektNotification.find_by(id: params[:id])
    @projekt_notification.update(projekt_notification_params)
    redirect_to request_referer, notice: t("admin.settings.flash.updated")
  end

  def destroy
    @projekt_notification = ProjektNotification.find_by(id: params[:id])
    @projekt_notification.destroy
    redirect_to(request.referer + '#tab-projekt-notifications')
  end

  private

  def projekt_notification_params
    params.require(:projekt_notification).permit(:title, :body)
  end

  def set_projekt
    @projekt = Projekt.find(params[:projekt_id])
  end

  def request_referer
    return request.referer + params[:projekt_notification][:tab] if params[:projekt_notification][:tab]

    request.referer
  end
end
