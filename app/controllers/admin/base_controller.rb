class Admin::BaseController < ApplicationController
  layout "admin"
  before_action :authenticate_user!

  skip_authorization_check
  before_action :verify_administrator

  private

    def verify_administrator
      return if updating_projekt_setting?

      raise CanCan::AccessDenied unless current_user&.administrator?
    end

    def updating_projekt_setting?
      controller_name == "projekt_settings" && action_name == "update" &&
        current_user&.projekt_manager?
    end
end
