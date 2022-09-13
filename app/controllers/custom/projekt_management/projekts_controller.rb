class ProjektManagement::ProjektsController < ProjektManagement::BaseController
  include ProjektAdminActions
  skip_authorization_check only: :index
  load_and_authorize_resource only: %i[edit update]

  helper_method :namespace_projekt_path

  def index
    if current_user.administrator?
      @projekts = Projekt.all
    elsif current_user.projekt_manager?
      @projekts = Projekt.where(projekt_manager: current_user)
    end
  end

  def namespace_projekt_path(projekt)
    projekt_management_projekt_path(projekt)
  end
end
