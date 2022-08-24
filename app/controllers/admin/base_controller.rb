class Admin::BaseController < ApplicationController
  layout "admin"
  before_action :authenticate_user!

  skip_authorization_check unless: :projekt_manager_action?
  before_action :verify_administrator, unless: :projekt_manager_action?

  private

    def verify_administrator
      raise CanCan::AccessDenied unless current_user&.administrator?
    end

    def projekt_manager_action?
      raise CanCan::AccessDenied unless current_user&.projekt_manager? || current_user&.administrator?

      return false if current_user&.projekt_manager?

      shared_controllers = [
        "admin/projekt_arguments",
        "admin/projekt_notifications",
        "admin/projekt_settings"
      ]

      params[:namespace] == "projekt_management" ||
        params[:controller].split("/").first == "projekt_management" ||
        (params[:controller].in?(shared_controllers) && current_user&.projekt_manager?) ||
        (params[:action] == "update_standard_phase" && current_user&.projekt_manager?)
    end

    def should_authorize_projekt_manager?
      current_user.projekt_manager? && !current_user.administrator?
    end
end
