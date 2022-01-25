require_dependency Rails.root.join("app", "controllers", "users", "sessions_controller").to_s

class Users::SessionsController < Devise::SessionsController

  private

    def after_sign_out_path_for(resource)
      if cookies[:keycloack_user]
        cookies.delete :keycloack_user
        redirect_path = @stored_location.present? && !@stored_location.match("management") ? @stored_location : super
        redirect_url = request.base_url + redirect_path
        Rails.application.secrets.openid_connect_sign_out_uri + "?redirect_uri=" + redirect_url
      else
        super
      end
    end
end
