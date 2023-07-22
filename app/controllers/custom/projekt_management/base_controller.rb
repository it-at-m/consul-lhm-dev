class ProjektManagement::BaseController < ApplicationController
  layout "admin"

  before_action :authenticate_user!
  before_action :redirect_administrator
  before_action :verify_projekt_manager

  private

    def redirect_administrator
      redirect_to admin_root_path if current_user&.administrator?
    end

    def verify_projekt_manager
      raise CanCan::AccessDenied unless current_user&.projekt_manager?
    end
end
