class Admin::ProjektPhasesController < Admin::BaseController
  include ProjektPhaseActions

  def create
    @projekt = Projekt.find(params[:projekt_id])
    ProjektPhase.create!(projekt_phase_params)

    redirect_to edit_admin_projekt_path(@projekt.id), notice: t("admin.projekt_phase.create.notice")
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
