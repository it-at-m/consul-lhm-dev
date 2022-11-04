require_dependency Rails.root.join("app", "models", "verification", "residence").to_s

class Verification::Residence
  attr_accessor :first_name, :last_name, :street_name, :street_number,
                :plz, :city_name, :document_last_digits, :date_of_birth, :gender

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :street_name, presence: true
  validates :street_number, presence: true
  validates :plz, presence: true
  validates :city_name, presence: true
  validates :gender, presence: true
  validates :date_of_birth, presence: true
  validate  :allowed_age
  validates :document_last_digits, presence: true, if: :document_last_digits_required?

  # validates :document_number, presence: true, unless: :manual_verification?
  # validates :document_type, presence: true, unless: :manual_verification?
  # validates :postal_code, presence: true, unless: :manual_verification?
  # validate :local_postal_code, unless: :manual_verification?
  # validate :local_residence, unless: :manual_verification?

  def save
    return false unless valid?

    user.update!(first_name:            first_name,                      #custom
                 last_name:             last_name,                       #custom
                 street_name:           street_name,                     #custom
                 street_number:         street_number,                   #custom
                 plz:                   plz,                             #custom
                 city_name:             city_name,                       #custom
                 document_last_digits:  document_last_digits,            #custom
                 geozone:               Geozone.find_with_plz(plz),      #custom
                 gender:                gender)
  end

  def document_number_uniqueness
    if User.active.where.not(id: user.id).where(document_number: document_number).any? &&
        !document_number.blank?
      errors.add(:document_number, I18n.t("errors.messages.taken"))
    end
  end

  def document_last_digits_required?
    Setting["extra_fields.verification.check_documents"].present?
  end
end
