class ProjektManagement::ProjektsController < ProjektManagement::BaseController
  include ProjektAdminActions

  def index
    authorize!(:index, Projekt)
    @projekts = Projekt.joins(:projekt_manager_assignments)
      .where("projekt_manager_assignments.projekt_manager_id = ? AND ? = ANY(projekt_manager_assignments.permissions)", current_user.projekt_manager.id, "manage")
  end
end
