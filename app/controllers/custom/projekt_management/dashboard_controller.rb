class ProjektManagement::DashboardController < ProjektManagement::BaseController
  skip_authorization_check only: [:index]

  def index
  end
end
