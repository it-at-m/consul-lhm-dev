require_dependency Rails.root.join("app", "controllers", "users", "registrations_controller").to_s

class Users::RegistrationsController < Devise::RegistrationsController
  def create
    build_resource(sign_up_params)
    resource.registering_from_web = true

    debugger
    if resource.valid?
      super
    else
      render :new
    end
  end

  private

    def sign_up_params
      debugger
      params[:user][:registered_address_id] = registered_address&.id
      params[:user][:registered_address_street_id] = registered_address_street&.id
      params[:user].delete(:redeemable_code) if params[:user].present? &&
                                                params[:user][:redeemable_code].blank?
      params.require(:user).permit(:username, :email,
                                   :first_name, :last_name, :street_number, :plz, :city_name,
                                   :registered_address_id, :registered_address_street_id, :city_street_id,
                                   :gender, :date_of_birth,
                                   :document_type, :document_last_digits,
                                   :password, :password_confirmation, :terms_of_service, :locale,
                                   :redeemable_code)
    end

    def registered_address
      return nil if registered_address_street.blank?

      street_number = params[:user][:registered_address_street_number]
      street_number_extension = params[:user][:registered_address_street_number_extension]
      plz = params[:user][:plz]
      city_name = params[:user][:city_name]

      return nil if street_number.blank? || plz.blank? || city_name.blank?

      registered_address_street.registered_addresses.where(
        "street_number = ? AND lower(street_number_extension) = ? AND plz = ? AND lower(city) = ?",
        street_number.strip,
        street_number_extension.strip.downcase,
        plz.strip,
        city_name.strip.downcase
      )&.first
    end

    def registered_address_street
      street_name = params[:user][:registered_address_street_name]
      plz = params[:user][:plz]

      return nil if street_name.blank? || plz.blank?

      RegisteredAddressStreet.where(
        "lower(name) = ? AND plz = ?",
        street_name.downcase.strip,
        plz.strip
      )&.first
    end
end
