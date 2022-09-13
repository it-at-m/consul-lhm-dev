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

  private

    def sign_up_params
      params[:user].delete(:redeemable_code) if params[:user].present? &&
                                                params[:user][:redeemable_code].blank?
      params.require(:user).permit(:username, :email,
                                   :first_name, :last_name, :street_name, :street_number, :plz, :city_name,
                                   :gender, :date_of_birth, :document_last_digits,
                                   :password, :password_confirmation, :terms_of_service, :locale,
                                   :redeemable_code)
    end
end
