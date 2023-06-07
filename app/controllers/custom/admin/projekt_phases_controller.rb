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

    def namespace_projekt_phase_path(projekt, projekt_phase)
      admin_projekt_projekt_phase_path(projekt, projekt_phase)
    end

    def edit_namespace_projekt_path(projekt)
      if projekt.special?
        admin_projekts_path(anchor: "tab-projekts-overview-page")
      else
        edit_admin_projekt_path(projekt)
      end
    end

    def projekt_phase_params
      params.require(:projekt_phase).permit(:projekt_id, :type)
    end
end
