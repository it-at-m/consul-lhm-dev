class ProjektManagement::ProjektPhasesController < ProjektManagement::BaseController
  include ProjektPhaseAdminActions

  def create
    authorize! :create, @projekt_phase
    super
  end

  def update
    authorize! :update, @projekt_phase
    super
  end

  def destroy
    authorize! :destroy, @projekt_phase
    super
  end
end
