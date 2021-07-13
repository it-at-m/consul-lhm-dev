require_dependency Rails.root.join("app", "controllers", "users", "registrations_controller").to_s
class Users::RegistrationsController < Devise::RegistrationsController

  def edit
    if current_user.keycloak_link
      redirect_to account_path
    end
  end
end
