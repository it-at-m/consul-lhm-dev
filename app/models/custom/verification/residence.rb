require_dependency Rails.root.join("app", "models", "verification", "residence").to_s

class Verification::Residence
  attr_accessor :first_name, :last_name, :gender, :date_of_birth,
                :city_name, :plz, :street_name, :street_number, :street_number_extension,
                :document_type, :document_last_digits,
                :form_registered_address_city_id,
                :form_registered_address_street_id,
                :form_registered_address_id,
                :city_street_id

  # validates :first_name, presence: true
  # validates :last_name, presence: true
  # validates :street_number, presence: true
  # validates :plz, presence: true
  # validates :city_name, presence: true
  # validates :gender, presence: true
  # validates :document_type, presence: true, if: :document_required?
  # validates :document_last_digits, presence: true, if: :document_required?

  def save
    return false unless valid?

    user.assign_attributes(
      first_name:            first_name,
      last_name:             last_name,
      city_street_id:        city_street_id,
      street_number:         street_number,
      plz:                   plz,
      city_name:             city_name,
      document_type:         document_type,
      document_last_digits:  document_last_digits,
      date_of_birth:         date_of_birth,
      geozone:               Geozone.find_with_plz(plz),
      gender:                gender,
    )

    user.send(:strip_whitespace)
    user.unique_stamp = user.prepare_unique_stamp

    return false unless user.stamp_unique?

    user.save!
  end

  def document_required?
    Setting["extra_fields.verification.check_documents"].present?
  end

  def show_no_registered_address_field?
    return true if RegisteredAddress::Street.none?

    form_registered_address_city_id == "0" ||
      form_registered_address_street_id == "0" ||
      form_registered_address_id == "0"
  end
end
