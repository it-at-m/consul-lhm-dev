module ProjektEventAdminActions
  extend ActiveSupport::Concern

  included do
    before_action :set_projekt_phase, :set_namespace
    before_action :set_projekt_event, only: [:update, :destroy, :send_notifications]
  end

  def create
    @projekt_event = ProjektEvent.new(projekt_event_params)
    @projekt_event.projekt_phase = @projekt_phase
    authorize!(:create, @projekt_event) unless current_user.administrator?

    @projekt_event.save!
    redirect_to polymorphic_path([@namespace, @projekt_phase, ProjektEvent]), notice: t("admin.settings.flash.updated")
  end

  def update
    authorize!(:update, @projekt_event) unless current_user.administrator?

    @projekt_event.update!(projekt_event_params)
    redirect_to polymorphic_path([@namespace, @projekt_phase, ProjektEvent]), notice: t("admin.settings.flash.updated")
  end

  def destroy
    authorize!(:destroy, @projekt_event) unless current_user.administrator?
    @projekt_event.destroy!

    redirect_to polymorphic_path([@namespace, @projekt_phase, ProjektEvent])
  end

  def send_notifications
    authorize!(:send_notifications, @projekt_event) unless current_user.administrator?
    NotificationServices::NewProjektEventNotifier.call(@projekt_event.id)
    redirect_to polymorphic_path([@namespace, @projekt_phase, ProjektEvent]),
      notice: t("custom.admin.projekts.edit.projekt_events_tab.notifications_sent_notice")
  end

  private

    def projekt_event_params
      params
        .require(:projekt_event)
        .permit(:projekt_phase_id, :title, :description, :location, :datetime, :end_datetime, :weblink)
    end

    def set_projekt_phase
      @projekt_phase = ProjektPhase.find(params[:projekt_phase_id])
    end

    def set_projekt_event
      @projekt_event = ProjektEvent.find_by(id: params[:id])
    end

    def set_namespace
      @namespace = params[:controller].split("/").first.to_sym
    end
end
