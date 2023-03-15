require_dependency Rails.root.join("app", "controllers", "users", "registrations_controller").to_s

class Users::RegistrationsController < Devise::RegistrationsController
  def create
    build_resource(sign_up_params)
    resource.registering_from_web = true

    if resource.valid?
      super
    else
      @registered_address_city = RegisteredAddress::City.find_by(id: params[:form_registered_address_city_id])
      @registered_address_street = RegisteredAddress::Street.find_by(id: params[:form_registered_address_street_id])
      @registered_address = RegisteredAddress.find_by(id: params[:form_registered_address_id])
      increase_error_count_for_registered_address_selectors
      render :new
    end
  end

  def update_registered_address_street_field
    @registered_address_city = RegisteredAddress::City
      .find_by(id: params[:form_registered_address_city_id])

    if @registered_address_city.present?
      @registered_address_streets = @registered_address_city.registered_address_streets.order(name: :asc)
    else
      @registered_address_streets = []
    end
  end

  def update_registered_address_field
    @registered_address_street = RegisteredAddress::Street
      .find_by(id: params[:form_registered_address_street_id])

    if @registered_address_street.present?
      @registered_addresses = @registered_address_street.registered_addresses
    else
      @registered_addresses = []
    end
  end

  private

    def sign_up_params
      set_related_params
      params[:user].delete(:redeemable_code) if params[:user].present? &&
                                                params[:user][:redeemable_code].blank?
      params.require(:user).permit(:username, :email,
                                   :first_name, :last_name, :street_number, :plz, :city_name,
                                   :registered_address_id, :city_street_id,
                                   :form_registered_address_city_id, :form_registered_address_street_id, :form_registered_address_id,
                                   :gender, :date_of_birth,
                                   :document_type, :document_last_digits,
                                   :password, :password_confirmation, :terms_of_service, :locale,
                                   :redeemable_code)
    end

    def set_related_params
      params[:user][:form_registered_address_city_id] = params[:form_registered_address_city_id]
      params[:user][:form_registered_address_street_id] = params[:form_registered_address_street_id]
      params[:user][:form_registered_address_id] = params[:form_registered_address_id]

      if params[:form_registered_address_id].present? && params[:form_registered_address_id] != "0"
        registered_address = RegisteredAddress.find(params[:form_registered_address_id])

        params[:user][:registered_address_id] = registered_address.id

        params[:user][:city_name] = registered_address.registered_address_city.name
        params[:user][:plz] = registered_address.registered_address_street.plz
        params[:user][:street_name] = registered_address.registered_address_street.name
        params[:user][:street_number] = registered_address.street_number
        params[:user][:street_number_extension] = registered_address.street_number_extension
      end
    end

    def increase_error_count_for_registered_address_selectors
      if RegisteredAddress::City.any?
        if params[:form_registered_address_city_id].blank?
          resource.errors.add(:form_registered_address_city_id, :blank)
        elsif params[:form_registered_address_street_id].blank?
          resource.errors.add(:form_registered_address_street_id, :blank)
        elsif params[:form_registered_address_id].blank?
          resource.errors.add(:form_registered_address_id, :blank)
        end
      end
    end
end
