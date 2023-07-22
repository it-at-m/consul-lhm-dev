module ProjektLivestreamAdminActions
  extend ActiveSupport::Concern

  included do
    before_action :set_projekt_phase, :set_namespace
    before_action :set_projekt_livestream, only: [:update, :destroy, :send_notifications]
  end

  def create
    @projekt_livestream = ProjektLivestream.new(projekt_livestream_params)
    @projekt_livestream.projekt_phase = @projekt_phase
    authorize!(:create, @projekt_livestream) unless current_user.administrator?

    @projekt_livestream.save!
    redirect_to polymorphic_path([@namespace, @projekt_phase, ProjektLivestream]), notice: t("admin.settings.flash.updated")
  end

  def update
    authorize!(:update, @projekt_livestream) unless current_user.administrator?

    @projekt_livestream.update!(projekt_livestream_params)
    redirect_to polymorphic_path([@namespace, @projekt_phase, ProjektLivestream]), notice: t("admin.settings.flash.updated")
  end

  def destroy
    authorize!(:destroy, @projekt_livestream) unless current_user.administrator?

    @projekt_livestream.destroy!
    redirect_to polymorphic_path([@namespace, @projekt_phase, ProjektLivestream])
  end

  def send_notifications
    @projekt_livestream = ProjektLivestream.find_by(id: params[:id])
    authorize!(:send_notifications, @projekt_livestream) unless current_user.administrator?

    NotificationServices::NewProjektLivestreamNotifier.call(@projekt_livestream.id)
    redirect_to polymorphic_path([@namespace, @projekt_phase, ProjektLivestream]),
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

    def set_namespace
      @namespace = params[:controller].split("/").first.to_sym
    end
end
