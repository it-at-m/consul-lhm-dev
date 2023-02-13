require_dependency Rails.root.join("app", "controllers", "verification", "residence_controller").to_s

class Verification::ResidenceController < ApplicationController
  def new
    current_user_attributes = current_user.attributes.transform_keys(&:to_sym).slice(*allowed_params)
    @residence = Verification::Residence.new(current_user_attributes)
  end

  def create
    @residence = Verification::Residence.new(residence_params.merge(user: current_user))

    if @residence.save
      NotificationServices::NewManualVerificationRequestNotifier.call(current_user.id) # remove unless manual
      redirect_to account_path, notice: t("custom.verification.residence.create.flash.success_manual")
    else
      redirect_to new_residence_path, notice: t("custom.verification.residence.create.flash.error")
    end
  end

  private

    def allowed_params
      [
        :document_number, :document_type, :date_of_birth, :postal_code, :terms_of_service,
        :first_name, :last_name, :city_street_id, :street_number,
        :plz, :city_name, :gender, :document_type, :document_last_digits
      ]
    end
end
