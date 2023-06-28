class ProjektManagement::ProjektPhasesController < ProjektManagement::BaseController
  include ProjektPhaseActions

  def edit
    authorize! :edit, @projekt_phase
    render "custom/admin/projekt_phases/edit"
  end

  def update
    authorize! :update, @projekt_phase
    super
  end

  private

    # def namespace_projekt_phase_path(projekt, projekt_phase)
    #   projekt_management_projekt_projekt_phase_path(projekt, projekt_phase)
    # end

    # def edit_namespace_projekt_path(projekt)
    #   edit_projekt_management_projekt_path(projekt)
    # end
end
