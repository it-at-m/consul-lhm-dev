class Admin::ProjektNotificationsController < Admin::BaseController
  before_action :set_projekt_phase
  before_action :set_namespace

  def create
    @projekt_notification = ProjektNotification.new(projekt_notification_params)
    @projekt_notification.projekt_phase = @projekt_phase

    if should_authorize_projekt_manager?
      authorize! :create, @projekt_notification
    end

    if @projekt_notification.save
      NotificationServices::NewProjektNotificationNotifier.call(@projekt_notification.id)
    end

    redirect_to redirect_path, notice: t("admin.settings.flash.updated")
  end

  def update
    @projekt_notification = ProjektNotification.find_by(id: params[:id])

    if should_authorize_projekt_manager?
      authorize! :update, @projekt_notification
    end

    @projekt_notification.update!(projekt_notification_params)
    redirect_to redirect_path, notice: t("admin.settings.flash.updated")
  end

  def destroy
    @projekt_notification = ProjektNotification.find_by(id: params[:id])

    if should_authorize_projekt_manager?
      authorize! :destroy, @projekt_notification
    end

    @projekt_notification.destroy!
    redirect_to redirect_path
  end

  private

    def projekt_notification_params
      params.require(:projekt_notification).permit(:projekt_phase_id, :title, :body)
    end

    def set_projekt_phase
      @projekt_phase = ProjektPhase.find_by(id: params[:projekt_phase_id])
    end

    def set_namespace
      @namespace = params[:controller].split("/").first.to_sym
    end

    def redirect_path
      polymorphic_path([@namespace, @projekt_phase], action: :projekt_notifications)
    end
end
