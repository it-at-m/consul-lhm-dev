class ProjektManagement::BaseController < ApplicationController
  layout "projekt_management"
  before_action :authenticate_user!

  before_action :verify_projekt_manager, :set_namespace

  helper_method :projekt_manager

  private

    def verify_projekt_manager
      raise ActionController::RoutingError, "Not Found" unless current_user&.projekt_manager?
    end

    def projekt_manager
      @projekt_manager ||= current_user.projekt_manager
    end

    def set_namespace
      @namespace ||= :projekt_management
    end
end
