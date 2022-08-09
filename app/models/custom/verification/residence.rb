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

  validates :document_number, presence: true, unless: :document_last_digits_required?
  validates :document_type, presence: true, unless: :document_last_digits_required?
  validates :postal_code, presence: true, unless: :plz_required?

  def save
    valid?

    return false unless errors.count == 1 && errors[:local_residence].present?

    user.update!(document_number:       document_number,
                 document_type:         document_type,
                 first_name:            first_name,            #custom
                 last_name:             last_name,             #custom
                 street_name:           street_name,           #custom
                 street_number:         street_number,         #custom
                 plz:                   plz,                   #custom
                 city_name:             city_name,             #custom
                 document_last_digits:  document_last_digits,  #custom
                 geozone:               geozone,
                 date_of_birth:         date_of_birth.in_time_zone.to_datetime,
                 gender:                gender,
                 residence_verified_at: Time.current)

    return false unless valid?

    user.take_votes_if_erased_document(document_number, document_type)
  end

  def document_number_uniqueness
    if User.active.where.not(id: user.id).where(document_number: document_number).any?
      errors.add(:document_number, I18n.t("errors.messages.taken"))
    end
  end


  def first_name_required?
    Setting["extra_fields.verification.first_name"]
  end

  def last_name_required?
    Setting["extra_fields.verification.last_name"]
  end

  def street_name_required?
    Setting["extra_fields.verification.street_name"]
  end

  def street_number_required?
    Setting["extra_fields.verification.street_number"]
  end

  def plz_required?
    Setting["extra_fields.verification.plz"]
  end

  def city_name_required?
    Setting["extra_fields.verification.city_name"]
  end

  def date_of_birth_required?
    Setting["extra_fields.verification.date_of_birth"]
  end

  def gender_required?
    Setting["extra_fields.verification.gender"]
  end

  def document_last_digits_required?
    Setting["extra_fields.verification.document_last_digits"]
  end
end
