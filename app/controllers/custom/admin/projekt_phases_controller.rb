class Admin::ProjektPhasesController < Admin::BaseController
  include ProjektPhaseActions

  def create
    super
  end

  def update
    super
  end

  def order_phases
    @projekt = Projekt.find(params[:projekt_id])
    @projekt.projekt_phases.order_phases(params[:ordered_list])
    head :ok
  end
end
