class Admin::ProjektEventsController < Admin::BaseController
  before_action :set_projekt

  def create
    @projekt_event = ProjektEvent.new(projekt_event_params)
    @projekt_event.projekt = @projekt

    authorize! :create, @projekt_event if params[:namespace] == "projekt_management"

    @projekt_event.save!

    redirect_to redirect_path(@projekt), notice: t("admin.settings.flash.updated")
  end

  def update
    @projekt_event = ProjektEvent.find_by(id: params[:id])
    @projekt_event.update!(projekt_event_params)

    authorize! :update, @projekt_event if params[:namespace] == "projekt_management"

    redirect_to redirect_path(@projekt), notice: t("admin.settings.flash.updated")
  end

  def destroy
    @projekt_event = ProjektEvent.find_by(id: params[:id])
    @projekt_event.destroy!

    authorize! :destroy, @projekt_event if params[:namespace] == "projekt_management"

    redirect_to redirect_path(@projekt)
  end

  private

    def projekt_event_params
      params.require(:projekt_event).permit(:title, :description, :location, :datetime, :weblink)
    end

    def set_projekt
      @projekt = Projekt.find(params[:projekt_id])
    end

    def redirect_path(projekt)
      if params[:namespace] == "projekt_management"
        edit_projekt_management_projekt_path(projekt) + "#tab-projekt-events"
      else
        edit_admin_projekt_path(projekt) + "#tab-projekt-events"
      end
    end
end
