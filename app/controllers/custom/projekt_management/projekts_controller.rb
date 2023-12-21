class ProjektManagement::ProjektsController < ProjektManagement::BaseController
  include ProjektAdminActions

  def index
    authorize!(:index, Projekt)
    @projekts = projekts_with_authorization_to("manage")
  end
end
