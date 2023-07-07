class ProjektManagement::ProjektsController < ProjektManagement::BaseController
  include ProjektAdminActions
  # skip_authorization_check only: :index

  def index
    if current_user.administrator?
      @projekts = Projekt.all
    elsif current_user.projekt_manager?
      @projekts = Projekt.where(projekt_manager: current_user)
    end
  end
end
