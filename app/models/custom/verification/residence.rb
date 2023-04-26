require_dependency Rails.root.join("app", "models", "verification", "residence").to_s

class Verification::Residence
  attr_accessor :first_name, :last_name, :gender, :date_of_birth,
                :city_name, :plz, :street_name, :street_number, :street_number_extension,
                :document_type, :document_last_digits,
                :registered_address_id,
                :form_registered_address_city_id,
                :form_registered_address_street_id,
                :form_registered_address_id

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :gender, presence: true
  validates :date_of_birth, presence: true

  validates :city_name, presence: true, if: :show_no_registered_address_field?
  validates :plz, presence: true, if: :show_no_registered_address_field?
  validates :street_name, presence: true, if: :show_no_registered_address_field?
  validates :street_number, presence: true, if: :show_no_registered_address_field?

  validates :document_type, presence: true, if: :document_required?
  validates :document_last_digits, presence: true, if: :document_required?

  validates :terms_data_storage, acceptance: { allow_nil: false } #custom
  validates :terms_data_protection, acceptance: { allow_nil: false } #custom
  validates :terms_general, acceptance: { allow_nil: false } #custom

  def save
    return false unless valid?

    if form_registered_address_id.present? && form_registered_address_id != "0"
      registered_address = RegisteredAddress.find(form_registered_address_id)

      registered_address_id = registered_address.id

      self.city_name = registered_address.registered_address_city.name
      self.plz = registered_address.registered_address_street.plz
      self.street_name = registered_address.registered_address_street.name
      self.street_number = registered_address.street_number
      self.street_number_extension = registered_address.street_number_extension
    end

    user.assign_attributes(
      first_name:              first_name,
      last_name:               last_name,
      gender:                  gender,
      date_of_birth:           date_of_birth,
      city_name:               city_name,
      plz:                     plz,
      street_name:             street_name,
      street_number:           street_number,
      street_number_extension: street_number_extension,
      document_type:           document_type,
      document_last_digits:    document_last_digits,
      registered_address_id:   registered_address_id
    )

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
