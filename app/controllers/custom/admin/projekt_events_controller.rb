class Admin::ProjektEventsController < Admin::BaseController
  before_action :set_projekt_phase
  before_action :set_projekt_event, only: [:update, :destroy, :send_notifications]

  def create
    @projekt_event = ProjektEvent.new(projekt_event_params)
    @projekt_event.projekt_phase = @projekt_phase

    if should_authorize_projekt_manager?
      authorize! :create, @projekt_event
    end

    @projekt_event.save!

    redirect_to redirect_path(@projekt_phase), notice: t("admin.settings.flash.updated")
  end

  def update
    @projekt_event = ProjektEvent.find_by(id: params[:id])
    @projekt_event.update!(projekt_event_params)

    if should_authorize_projekt_manager?
      authorize! :update, @projekt_event
    end

    redirect_to redirect_path(@projekt_phase), notice: t("admin.settings.flash.updated")
  end

  def destroy
    @projekt_event = ProjektEvent.find_by(id: params[:id])
    @projekt_event.destroy!

    if should_authorize_projekt_manager?
      authorize! :destroy, @projekt_event
    end

    redirect_to redirect_path(@projekt_phase)
  end

  def send_notifications
    NotificationServices::NewProjektEventNotifier.call(@projekt_event.id)
    redirect_to edit_admin_projekt_path(@projekt, anchor: "tab-projekt-events"),
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

    def redirect_path(projekt_phase)
      projekt_events_admin_projekt_phase_path(projekt_phase)
    end
end
