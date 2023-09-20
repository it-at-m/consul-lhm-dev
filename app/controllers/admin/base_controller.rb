class Admin::BaseController < ApplicationController
  layout "admin"
  before_action :authenticate_user!

  skip_authorization_check
  before_action :verify_administrator, :set_namespace

  private

    def verify_administrator
      return if allow_projekt_manager?

      raise CanCan::AccessDenied unless current_user&.administrator?
    end

    def allow_projekt_manager?
      return false unless current_user&.projekt_manager?

      projekt_setting_update_action ||
        projekt_phase_setting_update_action ||
        page_update_action
    end

    def projekt_setting_update_action
      controller_name == "projekt_settings" && action_name == "update"
    end

    def projekt_phase_setting_update_action
      controller_name == "projekt_phase_settings" && action_name == "update"
    end

    def page_update_action
      controller_name == "pages" && action_name == "update"
    end

    def set_namespace
      @namespace ||= :admin
    end
end
