require_dependency Rails.root.join("app", "controllers", "users", "omniauth_callbacks_controller").to_s
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  # START Ergänzung für Keycloak-Anbindung
  def openid_connect
    extra = request.env["omniauth.auth"].extra

    info = request.env["omniauth.auth"].info
    email = info["email"]
    username = info["name"]
    authlevel = extra.raw_info[:authlevel]
    keycloak_link = info["preferred_username"]

    user = User.find_by keycloak_link: keycloak_link

    unless user
      password = SecureRandom.base64(15)
      user = User.new({ email: email, username: username, oauth_email: email, terms_of_service: true, password:  password, password_confirmation: password, keycloak_link: keycloak_link })
      if extra.raw_info.email_verified
        user.skip_confirmation!
        user.verified_at = Time.now
      end
      if user.save
        sign_in user
      end
    else
      if user.administrator? && ["STORK-QAA-Level-3", "STORK-QAA-Level-4"].include?(authlevel)
        sign_in user
      elsif !user.administrator?
        sign_in user
      end
    end

    redirect_to after_sign_in_path_for(user)

    #sign_in_with :openid_connect_login, :openid_connect
  end
  # ENDE Ergänzung für Keycloak-Anbindung
end
