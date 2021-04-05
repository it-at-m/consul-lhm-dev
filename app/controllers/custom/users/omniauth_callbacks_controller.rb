require_dependency Rails.root.join("app", "controllers", "users", "omniauth_callbacks_controller").to_s
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  # START Ergänzung für Keycloak-Anbindung
  def openid_connect
    sign_in_with :openid_connect_login, :openid_connect
  end
  # ENDE Ergänzung für Keycloak-Anbindung
end
