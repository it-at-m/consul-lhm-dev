require_dependency Rails.root.join("app", "models", "verification", "residence").to_s

class Verification::Residence
  attr_accessor :first_name, :last_name, :street_name, :street_number,
                :plz, :city_name, :document_last_digits, :date_of_birth, :gender

  validates :first_name, presence: true, if: :first_name_required?
  validates :last_name, presence: true, if: :last_name_required?
  validates :street_name, presence: true, if: :street_name_required?
  validates :street_number, presence: true, if: :street_number_required?
  validates :plz, presence: true, if: :plz_required?
  validates :city_name, presence: true, if: :city_name_required?
  validates :gender, presence: true, if: :gender_required?
  validates :document_last_digits, presence: true, if: :document_last_digits_required?

  validates :document_number, presence: true, unless: :manual_verification?
  validates :document_type, presence: true, unless: :manual_verification?
  validates :postal_code, presence: true, unless: :manual_verification?
  validate :local_postal_code, unless: :manual_verification?
  validate :local_residence, unless: :manual_verification?

  def save_manual_verification
    return false unless valid?

    user.update!(first_name:            first_name,            #custom
                 last_name:             last_name,             #custom
                 street_name:           street_name,           #custom
                 street_number:         street_number,         #custom
                 plz:                   plz,                   #custom
                 city_name:             city_name,             #custom
                 document_last_digits:  document_last_digits,  #custom
                 geozone:               geozone_with_plz,      #custom
                 gender:                gender)
  end

  def geozone_with_plz
    return nil unless plz.present?

    Geozone.where.not(postal_codes: nil).select do |geozone|
      geozone.postal_codes.split(",").any? do |postal_code|
        postal_code.strip == plz
      end
    end.first
  end

  def document_number_uniqueness
    if User.active.where.not(id: user.id).where(document_number: document_number).any? &&
        !document_number.blank?
      errors.add(:document_number, I18n.t("errors.messages.taken"))
    end
  end

  def manual_verification?
    Setting["extended_feature.verification.manual_verifications"].present?
  end

  def first_name_required?
    manual_verification? &&
      Setting["extra_fields.verification.first_name"].present?
  end

  def last_name_required?
    manual_verification? &&
      Setting["extra_fields.verification.last_name"].present?
  end

  def street_name_required?
    manual_verification? &&
      Setting["extra_fields.verification.street_name"].present?
  end

  def street_number_required?
    manual_verification? &&
      Setting["extra_fields.verification.street_number"].present?
  end

  def plz_required?
    manual_verification? &&
      Setting["extra_fields.verification.plz"].present?
  end

  def city_name_required?
    manual_verification? &&
      Setting["extra_fields.verification.city_name"].present?
  end

  def date_of_birth_required?
    manual_verification? &&
      Setting["extra_fields.verification.date_of_birth"].present?
  end

  def gender_required?
    manual_verification? &&
      Setting["extra_fields.verification.gender"].present?
  end

  def document_last_digits_required?
    manual_verification? &&
      Setting["extra_fields.verification.document_last_digits"].present?
  end
end
