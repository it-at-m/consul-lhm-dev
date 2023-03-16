require_dependency Rails.root.join("app", "controllers", "users", "omniauth_callbacks_controller").to_s
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  # START Ergänzung für Keycloak-Anbindung
  def openid_connect
    keycloak_id_token = request.env["omniauth.auth"].credentials.id_token

    extra = request.env["omniauth.auth"].extra

    info = request.env["omniauth.auth"].info
    email = info["email"]
    username = info["name"]
    authlevel = extra.raw_info[:authlevel]
    keycloak_link = extra.raw_info["preferred_username"]

    if User.only_hidden.find_by(email: email)
      redirect_to new_user_registration_path(reason: "uh") and return
    end

    if user = User.find_by(keycloak_link: keycloak_link) #keycloak user logged in in the past
      if user.email == email #keycloak user didn't change his email in keycloak
        sign_in user

      else #email changed in keycloak after logging in with old email
        if User.find_by(email: email) #new keycloak email already taken by other user
          redirect_to new_user_session_url(reason: "ee") and return
        else
          user.assign_attributes(
            email: email,
            keycloak_id_token: keycloak_id_token)
          user.skip_reconfirmation!
          user.save!

          sign_in user
        end
      end

    else
      if user = User.find_by(email: email) #keycloak email already taken by other user
        redirect_to new_user_session_url(reason: "ee") and return
      else
        password = SecureRandom.base64(15)
        user = User.create!({
          email: email,
          username: username,
          oauth_email: email,
          terms_of_service: true,
          password: password,
          password_confirmation: password,
          keycloak_link: keycloak_link,
          keycloak_id_token: keycloak_id_token,
          confirmed_at: Time.zone.now,
          registering_with_oauth: true
        })

        if User.find_by(username: username, registering_with_oauth: false)
          sign_in user
          redirect_to finish_signup_path
          return
        end
      end

      sign_in user
    end

    redirect_to after_sign_in_path_for(user), notice: t("cli.devise.success")

    # if user.administrator? && ["STORK-QAA-Level-3", "STORK-QAA-Level-4"].include?(authlevel)
    #   sign_in user
    # elsif !user.administrator?
    #   sign_in user
    # end

    #sign_in_with :openid_connect_login, :openid_connect
  end
  # ENDE Ergänzung für Keycloak-Anbindung

  def after_sign_in_path_for(resource)
    # if resource.registering_with_oauth && !resource.valid?
    #   finish_signup_path
    # else
      resource.update!(registering_with_oauth: false)
      super(resource)
    # end
  end

  alias_method :bayern_id, :openid_connect
end
