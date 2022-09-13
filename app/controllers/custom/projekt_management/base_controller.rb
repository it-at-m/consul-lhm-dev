class ProjektManagement::BaseController < ApplicationController
  layout "admin"

  before_action :authenticate_user!
  before_action :verify_projekt_manager

  private

    def verify_projekt_manager
      raise CanCan::AccessDenied unless current_user&.projekt_manager?
    end
end
