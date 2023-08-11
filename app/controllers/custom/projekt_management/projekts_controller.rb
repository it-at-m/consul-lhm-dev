class ProjektManagement::ProjektsController < ProjektManagement::BaseController
  include ProjektAdminActions

  def index
    authorize!(:index, Projekt)
    @projekts = Projekt.with_pm_permission_to("manage", projekt_manager)
  end
end
