require_dependency Rails.root.join("app", "controllers", "verification", "residence_controller").to_s

class Verification::ResidenceController < ApplicationController
  include HasRegisteredAddress

  def new
    current_user_attributes = current_user.attributes.transform_keys(&:to_sym).slice(*allowed_params)
    @residence = Verification::Residence.new(current_user_attributes)
    @registered_address_city = current_user.registered_address_city
    @registered_address_street = current_user.registered_address_street
    @registered_address = current_user.registered_address
    if @registered_address_city.blank?
      @selected_city_id = "0" if @registered_address_city.blank?
      @residence.form_registered_address_city_id = "0"
    end
  end

  def create
    @residence = Verification::Residence.new(residence_params.merge(user: current_user))
    process_temp_attributes_for(@residence)

    if @residence.errors.none? && @residence.save
      NotificationServices::NewManualVerificationRequestNotifier.call(current_user.id) # remove unless manual
      redirect_to account_path, notice: t("custom.verification.residence.create.flash.success_manual")
    else
      set_address_objects_from_temp_attributes_for(@residence)
      render :new #, alert: t("custom.verification.residence.create.flash.error")
    end
  end

  private

    def allowed_params
      [
        :first_name, :last_name, :gender, :date_of_birth,
        :city_name, :plz, :street_name, :street_number, :street_number_extension,
        :document_type, :document_last_digits,
        :terms_data_storage, :terms_data_protection, :terms_general,
        :registered_address_id, :terms_of_service
      ]
    end
end
