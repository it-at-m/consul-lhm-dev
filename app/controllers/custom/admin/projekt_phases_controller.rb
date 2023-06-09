class Admin::ProjektPhasesController < Admin::BaseController
  include ProjektPhaseActions

  def create
    @projekt = Projekt.find(params[:projekt_id])
    ProjektPhase.create!(projekt_phase_params)

    redirect_to edit_admin_projekt_path(@projekt.id), notice: t("admin.projekt_phase.create.notice")
  end

  def edit
    @registered_address_groupings = RegisteredAddress::Grouping.all
    @individual_groups = IndividualGroup.visible
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

  private

    def namespace_projekt_phase_path(action: "update")
      url_for(controller: "admin/projekt_phases", action: action, only_path: true)
    end
end
