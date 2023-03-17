require_dependency Rails.root.join("app", "models", "user").to_s

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :confirmable, :recoverable, :rememberable,
         :timeoutable,
         :trackable, :validatable, :omniauthable, :password_expirable, :secure_validatable,
         authentication_keys: [:login]

  delegate :registered_address_street, to: :registered_address

  attr_accessor :form_registered_address_city_id,
                :form_registered_address_street_id,
                :form_registered_address_id

  before_validation :strip_whitespace

  before_create :set_default_privacy_settings_to_false, if: :gdpr_conformity?
  after_create :take_votes_from_erased_user
  after_save :update_qualified_votes_count_for_budget_investments

  has_many :projekts, -> { with_hidden }, foreign_key: :author_id, inverse_of: :author
  has_many :projekt_questions, foreign_key: :author_id #, inverse_of: :author
  has_many :deficiency_reports, -> { with_hidden }, foreign_key: :author_id, inverse_of: :author
  has_one :deficiency_report_officer, class_name: "DeficiencyReport::Officer"
  has_one :projekt_manager
  belongs_to :city_street, optional: true
  belongs_to :registered_address, optional: true

  scope :projekt_managers, -> { joins(:projekt_manager) }

  validates :first_name, presence: true, on: :create, if: :extended_registration?
  validates :last_name, presence: true, on: :create, if: :extended_registration?
  validates :gender, presence: true, on: :create, if: :extended_registration?
  validates :date_of_birth, presence: true, on: :create, if: :extended_registration?

  validates :city_name, presence: true, on: :create, if: :show_no_registered_address_field?
  validates :plz, presence: true, on: :create, if: :show_no_registered_address_field?
  validates :street_name, presence: true, on: :create, if: :show_no_registered_address_field?
  validates :street_number, presence: true, on: :create, if: :show_no_registered_address_field?

  validates :document_type, presence: true, on: :create, if: :document_required?
  validates :document_last_digits, presence: true, on: :create, if: :document_required?

  def show_no_registered_address_field?
    return false unless extended_registration?
    return true if RegisteredAddress::Street.none?

    form_registered_address_city_id == "0" ||
      form_registered_address_street_id == "0" ||
      form_registered_address_id == "0"
  end

  def verify!
    return false unless stamp_unique?

    take_votes_from_erased_user
    update_columns(
      verified_at: Time.current,
      unique_stamp: prepare_unique_stamp,
      geozone_id: geozone_with_plz&.id
    )
  end

  def take_votes_from_erased_user
    return if erased?

    erased_user = User.erased.find_by(unique_stamp: unique_stamp)

    if erased_user.present?
      take_votes_from(erased_user)
      erased_user.update!(unique_stamp: nil)
    end
  end

  def stamp_unique?
    User.where.not(id: id).find_by(unique_stamp: prepare_unique_stamp).blank?
  end

  def prepare_unique_stamp
    return nil if first_name.blank? || last_name.blank? || date_of_birth.blank? || plz.blank?

    first_name.downcase + "_" +
      last_name.downcase + "_" +
      date_of_birth.to_date.strftime("%Y_%m_%d") + "_" +
      plz.to_s
  end

  def gdpr_conformity?
    Setting["extended_feature.gdpr.gdpr_conformity"].present?
  end

  def set_default_privacy_settings_to_false
    self.public_activity = false
    self.public_interests = false
    self.email_on_comment = false
    self.email_on_comment_reply = false
    self.newsletter = false
    self.email_digest = false
    self.email_on_direct_message = false
  end

  def deficiency_report_votes(deficiency_reports)
    voted = votes.for_deficiency_reports(Array(deficiency_reports).map(&:id))
    voted.each_with_object({}) { |v, h| h[v.votable_id] = v.value }
  end

  def deficiency_report_officer?
    deficiency_report_officer.present?
  end

  def projekt_manager?
    projekt_manager.present?
  end

  # def first_name_required?
  #   !organization? && !erased? && Setting["extra_fields.registration.extended"]
  # end

  # def last_name_required?
  #   !organization? && !erased? && Setting["extra_fields.registration.extended"]
  # end

  # def street_name_required?
  #   !organization? && !erased? && Setting["extra_fields.registration.extended"]
  # end

  # def street_number_required?
  #   !organization? && !erased? && Setting["extra_fields.registration.extended"]
  # end

  # def plz_required?
  #   !organization? && !erased? && Setting["extra_fields.registration.extended"]
  # end

  # def city_name_required?
  #   !organization? && !erased? && Setting["extra_fields.registration.extended"]
  # end

  # def date_of_birth_required?
  #   !organization? && !erased? && Setting["extra_fields.registration.extended"]
  # end

  # def gender_required?
  #   !organization? && !erased? && Setting["extra_fields.registration.extended"]
  # end

  def extended_registration?
    !organization? && !erased? && Setting["extra_fields.registration.extended"]
  end

  def document_required?
    !organization? && !erased? && Setting["extra_fields.registration.check_documents"]
  end

  def current_city_citizen?
    return false if geozone.nil?

    @geozone_ids ||= Geozone.ids

    @geozone_ids.include?(geozone.id)
  end

  def not_current_city_citizen?
    !current_city_citizen?
  end

  def verified?
    !unverified?
  end

  private

    def update_qualified_votes_count_for_budget_investments
      Budget::Ballot.where(user_id: id).find_each do |ballot|
        ballot.investments.each do |investment|
          investment.update(qualified_votes_count: investment.budget_ballot_lines.joins(ballot: :user).where.not(ballot: { users: { verified_at: nil } }).sum(:line_weight))
        end
      end
    end

    def geozone_with_plz
      Geozone.find_with_plz(plz)
    end

    def strip_whitespace
      self.first_name = first_name.strip unless first_name.nil?
      self.last_name = last_name.strip unless last_name.nil?
      self.city_name = city_name.strip unless city_name.nil?
      self.street_name = street_name.strip unless street_name.nil?
      self.street_number = street_number.strip unless street_number.nil?
      self.street_number_extension = street_number_extension.strip unless street_number_extension.nil?
    end
end
