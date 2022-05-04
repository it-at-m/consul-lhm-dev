class Admin::ProjektEventsController < Admin::BaseController
  before_action :set_projekt, except: :destroy

  def create
    @projekt_event = ProjektEvent.new(projekt_event_params)
    @projekt_event.projekt = @projekt
    @projekt_event.save
    redirect_to request_referer, notice: t("admin.settings.flash.updated")
  end

  def update
    @projekt_event = ProjektEvent.find_by(id: params[:id])
    @projekt_event.update(projekt_event_params)
    redirect_to request_referer, notice: t("admin.settings.flash.updated")
  end

  def destroy
    @projekt_event = ProjektEvent.find_by(id: params[:id])
    @projekt_event.destroy
    redirect_to(request.referer + '#tab-projekt-events')
  end

  private

  def projekt_event_params
    params.require(:projekt_event).permit(:title, :location, :datetime, :weblink)
  end

  def set_projekt
    @projekt = Projekt.find(params[:projekt_id])
  end

  def request_referer
    return request.referer + params[:projekt_event][:tab] if params[:projekt_event][:tab]

    request.referer
  end
end
