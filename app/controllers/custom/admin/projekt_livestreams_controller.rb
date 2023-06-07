class Admin::ProjektLivestreamsController < Admin::BaseController
  before_action :set_projekt
  before_action :set_namespace, only: %i[create update]

  def create
    @projekt_livestream = ProjektLivestream.new(projekt_livestream_params)
    @projekt_livestream.projekt = @projekt

    if should_authorize_projekt_manager?
      authorize! :create, @projekt_livestream
    end

    @projekt_livestream.save!

    redirect_to redirect_path(@projekt), notice: t("admin.settings.flash.updated")
  end

  def update
    @projekt_livestream = ProjektLivestream.find_by(id: params[:id])
    @projekt_livestream.update!(projekt_livestream_params)

    if should_authorize_projekt_manager?
      authorize! :update, @projekt_livestream
    end

    redirect_to redirect_path(@projekt), notice: t("admin.settings.flash.updated")
  end

  def destroy
    @projekt_livestream = ProjektLivestream.find_by(id: params[:id])
    @namespace = params[:namespace]

    if should_authorize_projekt_manager?
      authorize! :destroy, @projekt_livestream
    end

    @projekt_livestream.destroy!
    redirect_to redirect_path(@projekt)
  end

  def send_notifications
    @projekt_livestream = ProjektLivestream.find_by(id: params[:id])
    NotificationServices::NewProjektLivestreamNotifier.call(@projekt_livestream.id)
    redirect_to edit_admin_projekt_path(@projekt, anchor: "tab-projekt-livestreams"),
      notice: t("custom.admin.projekts.edit.projekt_livestreams_tab.notifications_sent_notice")
  end

  private

    def projekt_livestream_params
      params.require(:projekt_livestream).permit(:url, :title, :starts_at, :description)
    end

    def set_projekt
      @projekt = Projekt.find(params[:projekt_id])
    end

    def set_namespace
      @namespace = params[:projekt_livestream][:namespace]
    end

    def redirect_path(projekt)
      if params[:namespace] == "projekt_management"
        edit_projekt_management_projekt_path(projekt) + "#tab-projekt-livestreams"
      else
        edit_admin_projekt_path(projekt) + "#tab-projekt-livestreams"
      end
    end
end
