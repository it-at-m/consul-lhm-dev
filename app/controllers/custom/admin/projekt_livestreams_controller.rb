class Admin::ProjektLivestreamsController < Admin::BaseController
  before_action :set_projekt_phase
  before_action :set_projekt_livestream, only: [:update, :destroy, :send_notifications]

  def create
    @projekt_livestream = ProjektLivestream.new(projekt_livestream_params)
    @projekt_livestream.projekt_phase = @projekt_phase

    if should_authorize_projekt_manager?
      authorize! :create, @projekt_livestream
    end

    @projekt_livestream.save!
    redirect_to redirect_path(@projekt_phase), notice: t("admin.settings.flash.updated")
  end

  def update
    @projekt_livestream.update!(projekt_livestream_params)

    if should_authorize_projekt_manager?
      authorize! :update, @projekt_livestream
    end

    redirect_to redirect_path(@projekt_phase), notice: t("admin.settings.flash.updated")
  end

  def destroy
    if should_authorize_projekt_manager?
      authorize! :destroy, @projekt_livestream
    end

    @projekt_livestream.destroy!
    redirect_to redirect_path(@projekt_phase)
  end

  def send_notifications
    @projekt_livestream = ProjektLivestream.find_by(id: params[:id])
    NotificationServices::NewProjektLivestreamNotifier.call(@projekt_livestream.id)
    redirect_to edit_admin_projekt_path(@projekt, anchor: "tab-projekt-livestreams"),
      notice: t("custom.admin.projekts.edit.projekt_livestreams_tab.notifications_sent_notice")
  end

  private

    def projekt_livestream_params
      params.require(:projekt_livestream).permit(:projekt_phase_id, :url, :title, :starts_at, :description)
    end

    def set_projekt_phase
      @projekt_phase = ProjektPhase.find(params[:projekt_phase_id])
    end

    def set_projekt_livestream
      @projekt_livestream = ProjektLivestream.find_by(id: params[:id])
    end

    def redirect_path(projekt)
      projekt_livestreams_admin_projekt_phase_path(@projekt_phase)
    end
end
