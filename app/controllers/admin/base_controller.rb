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
        projekt_update_standard_phase_action ||
        projekt_phase_setting_update_action ||
        projekt_phase_toggle_active_status_action ||
        page_update_action
    end

    def projekt_setting_update_action
      controller_name == "projekt_settings" && action_name == "update"
    end

    def projekt_update_standard_phase_action
      controller_name == "projekts" && action_name == "update_standard_phase"
    end

    def projekt_phase_setting_update_action
      controller_name == "projekt_phase_settings" && action_name == "update"
    end

    def projekt_phase_toggle_active_status_action
      controller_name == "projekt_phases" && action_name == "toggle_active_status"
    end

    def page_update_action
      controller_name == "pages" && action_name == "update"
    end

    def set_namespace
      @namespace ||= :admin
    end
end
