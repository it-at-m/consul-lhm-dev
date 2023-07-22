module ProjektNotificationAdminActions
  extend ActiveSupport::Concern

  included do
    before_action :set_projekt_phase, :set_namespace
    before_action :set_projekt_notification, only: [:edit, :update, :destroy]
  end

  def create
    @projekt_notification = @projekt_phase.projekt_notifications.new(projekt_notification_params)
    authorize!(:create, @projekt_notification) unless current_user.administrator?

    if @projekt_notification.save
      NotificationServices::NewProjektNotificationNotifier.call(@projekt_notification.id)
    end

    redirect_to polymorphic_path([@namespace, @projekt_phase, ProjektNotification]),
      notice: t("admin.settings.flash.updated")
  end

  def update
    authorize!(:update, @projekt_notification) unless current_user.administrator?

    @projekt_notification.update!(projekt_notification_params)
    redirect_to polymorphic_path([@namespace, @projekt_phase, ProjektNotification]),
      notice: t("admin.settings.flash.updated")
  end

  def destroy
    authorize!(:destroy, @projekt_notification) unless current_user.administrator?

    @projekt_notification.destroy!
    redirect_to polymorphic_path([@namespace, @projekt_phase, ProjektNotification])
  end

  private

    def projekt_notification_params
      params.require(:projekt_notification).permit(:projekt_phase_id, :title, :body)
    end

    def set_projekt_phase
      @projekt_phase = ProjektPhase.find_by(id: params[:projekt_phase_id])
    end

    def set_projekt_notification
      @projekt_notification = ProjektNotification.find_by(id: params[:id])
    end

    def set_namespace
      @namespace = params[:controller].split("/").first.to_sym
    end
end
