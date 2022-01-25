require_dependency Rails.root.join("app", "controllers", "users", "omniauth_callbacks_controller").to_s
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  # START Ergänzung für Keycloak-Anbindung
  def openid_connect
    extra = request.env["omniauth.auth"].extra

    info = request.env["omniauth.auth"].info
    email = info["email"]
    username = info["name"]
    authlevel = extra.raw_info[:authlevel]
    keycloak_link = extra.raw_info["preferred_username"]

    if validate_absolute_email_uniqueness(email)
      @hidden_user_with_this_email_exists = true
      redirect_to new_user_registration_path(reason: 'uh') and return
    end

    user = User.find_by keycloak_link: keycloak_link

    unless user
      password = SecureRandom.base64(15)
      user = User.new({ email: email, username: username, oauth_email: email, terms_of_service: true, password:  password, password_confirmation: password, keycloak_link: keycloak_link, registering_with_oauth: true })

      user.skip_confirmation!
      user.verified_at = Time.now

      if User.find_by(email: email)
        redirect_to new_user_session_path, alert: t('cli.account.email_taken') and return
      end

      if user.save
        sign_in user
      end
    else
      if user.email != email
        if User.find_by(email: email)
          redirect_to new_user_session_path, alert: t('cli.account.email_taken') and return
        else
          user.assign_attributes(email: email)
          user.skip_reconfirmation!
          user.save
        end
      end

      if user.administrator? && ["STORK-QAA-Level-3", "STORK-QAA-Level-4"].include?(authlevel)
        sign_in user
      elsif !user.administrator?
        sign_in user
      end
    end

    cookies[:keycloack_user] = true

    redirect_to after_sign_in_path_for(user)

    #sign_in_with :openid_connect_login, :openid_connect
  end
  # ENDE Ergänzung für Keycloak-Anbindung

  def after_sign_in_path_for(resource)
    if resource.registering_with_oauth && !resource.valid?
      finish_signup_path
    else
      resource.update(registering_with_oauth: false)
      super(resource)
    end
  end

  def validate_absolute_email_uniqueness(email)
    if email.present?
      hidden_user_with_same_email = User.only_hidden.find_by(email: email)

      hidden_user_with_same_email.present?
    end
  end
end
