require_dependency Rails.root.join("app", "controllers", "users", "registrations_controller").to_s

class Users::RegistrationsController < Devise::RegistrationsController

  def create
    build_resource(sign_up_params)

    if resource.valid?
      validate_absolute_email_uniqueness
      if @user.errors.any?
        render :new
      else
        super
      end
    else
      validate_absolute_email_uniqueness
      render :new
    end
  end

  def validate_absolute_email_uniqueness
    if @user.present? && @user.email.present?
      hidden_user_with_same_email = User.only_hidden.find_by(email: @user.email)

      if hidden_user_with_same_email.present?
         @hidden_user_with_this_email_exists = true
         @user.errors.add(:email, :taken)
      end
    end
  end
end
