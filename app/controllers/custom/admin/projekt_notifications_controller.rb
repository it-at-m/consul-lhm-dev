class Admin::ProjektNotificationsController < Admin::BaseController
  before_action :set_projekt
  before_action :set_namespace, only: %i[create update]

  def create
    @projekt_notification = ProjektNotification.new(projekt_notification_params)
    @projekt_notification.projekt = @projekt

    if should_authorize_projekt_manager?
      authorize! :create, @projekt_notification
    end

    if @projekt_notification.save
      NotificationServices::NewProjektNotificationNotifier.call(@projekt_notification.id)
    end

    redirect_to redirect_path(@projekt), notice: t("admin.settings.flash.updated")
  end

  def update
    @projekt_notification = ProjektNotification.find_by(id: params[:id])

    if should_authorize_projekt_manager?
      authorize! :update, @projekt_notification
    end

    @projekt_notification.update!(projekt_notification_params)
    redirect_to redirect_path(@projekt), notice: t("admin.settings.flash.updated")
  end

  def destroy
    @projekt_notification = ProjektNotification.find_by(id: params[:id])
    @namespace = params[:namespace]

    if should_authorize_projekt_manager?
      authorize! :destroy, @projekt_notification
    end

    @projekt_notification.destroy!
    redirect_to redirect_path(@projekt)
  end

  private

    def projekt_notification_params
      params.require(:projekt_notification).permit(:title, :body)
    end

    def set_projekt
      @projekt = Projekt.find(params[:projekt_id])
    end

    def set_namespace
      @namespace = params[:projekt_notification][:namespace]
    end

    def redirect_path(projekt)
      if @namespace == "projekt_management"
        edit_projekt_management_projekt_path(projekt) + "#tab-projekt-notifications"
      else
        edit_admin_projekt_path(projekt) + "#tab-projekt-notifications"
      end
    end
end
