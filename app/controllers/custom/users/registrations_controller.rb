require_dependency Rails.root.join("app", "controllers", "users", "registrations_controller").to_s

class Users::RegistrationsController < Devise::RegistrationsController
  include HasRegisteredAddress

  def create
    build_resource(sign_up_params)
    resource.registering_from_web = true

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
      set_related_params
      params[:user].delete(:redeemable_code) if params[:user].present? &&
                                                params[:user][:redeemable_code].blank?
      params.require(:user).permit(:username, :email,
                                   :first_name, :last_name,
                                   :city_name, :plz, :street_name, :street_number, :street_number_extension,
                                   :registered_address_id,
                                   :gender, :date_of_birth,
                                   :document_type, :document_last_digits,
                                   :password, :password_confirmation,
                                   :terms_of_service, :terms_data_storage, :terms_data_protection, :terms_general,
                                   :locale,
                                   :redeemable_code,
                                   individual_group_value_ids: [])
    end

    def set_related_params
      params[:user][:form_registered_address_city_id] = params[:form_registered_address_city_id]
      params[:user][:form_registered_address_street_id] = params[:form_registered_address_street_id]
      params[:user][:form_registered_address_id] = params[:form_registered_address_id]

      if params[:form_registered_address_id].present?
        registered_address = RegisteredAddress.find(params[:form_registered_address_id])

        params[:user][:registered_address_id] = registered_address.id

        params[:user][:city_name] = registered_address.registered_address_city.name
        params[:user][:plz] = registered_address.registered_address_street.plz
        params[:user][:street_name] = registered_address.registered_address_street.name
        params[:user][:street_number] = registered_address.street_number
        params[:user][:street_number_extension] = registered_address.street_number_extension
      end
    end
end
