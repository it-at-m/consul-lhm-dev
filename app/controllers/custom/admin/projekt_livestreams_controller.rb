class Admin::ProjektLivestreamsController < Admin::BaseController
  before_action :set_projekt
  before_action :set_namespace, only: %i[create update]

  def create
    @projekt_livestream = ProjektLivestream.new(projekt_livestream_params)
    @projekt_livestream.projekt = @projekt

    authorize! :create, @projekt_livestream if params[:namespace] == "projekt_management"

    @projekt_livestream.save!

    redirect_to redirect_path(@projekt), notice: t("admin.settings.flash.updated")
  end

  def update
    @projekt_livestream = ProjektLivestream.find_by(id: params[:id])
    @projekt_livestream.update!(projekt_livestream_params)

    authorize! :update, @projekt_livestream if params[:namespace] == "projekt_management"

    redirect_to redirect_path(@projekt), notice: t("admin.settings.flash.updated")
  end

  def destroy
    @projekt_livestream = ProjektLivestream.find_by(id: params[:id])
    @namespace = params[:namespace]

    authorize! :destroy, @projekt_livestream if params[:namespace] == "projekt_management"

    @projekt_livestream.destroy!
    redirect_to redirect_path(@projekt)
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
