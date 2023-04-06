require_dependency Rails.root.join("app", "controllers", "users", "registrations_controller").to_s

class Users::RegistrationsController < Devise::RegistrationsController
  include HasRegisteredAddress

  def create
    build_resource(sign_up_params)
    resource.registering_from_web = true

    if resource.valid?
      super
    else
      set_registered_address_instance_variables
      increase_error_count_for_registered_address_selectors
      render :new
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
                                   :redeemable_code)
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
