require_dependency Rails.root.join("app", "models", "proposal").to_s
class Proposal < ApplicationRecord

  belongs_to :projekt, optional: true
  has_one :proposal_phase, through: :projekt
  has_many :geozone_restrictions, through: :proposal_phase
  has_many :geozone_affiliations, through: :projekt

  validates :projekt_id, presence: true
  validate :description_sanitized

  scope :with_current_projekt,  -> { joins(:projekt).merge(Projekt.current) }
  scope :by_author, -> (user_id) {
    return if user_id.nil?

    where(author_id: user_id)
  }

  scope :seen, -> { where.not(ignored_flag_at: nil) }
  scope :unseen, -> { where(ignored_flag_at: nil) }

  alias_attribute :projekt_phase, :proposal_phase

  def self.base_selection(scoped_projekt_ids = Projekt.ids)
    published.
      not_archived.
      not_retired.
      where(projekt_id: scoped_projekt_ids).
      joins(:projekt).merge(Projekt.activated)
  end

  def votable_by?(user)
    user.present? &&
      !user.organization? &&
      user.level_two_or_three_verified? &&
      (
        Setting['feature.user.skip_verification'].present? ||
        projekt.blank? ||
        proposal_phase.present? && proposal_phase.geozone_restrictions.blank? ||
        (proposal_phase.present? && proposal_phase.geozone_restrictions.any? && proposal_phase.geozone_restrictions.include?(user.geozone) )
      ) &&
      (
        projekt.blank? ||
        proposal_phase.present? && proposal_phase.current?
      )
  end

  def comments_allowed?(user)
    projekt.present? ? proposal_phase.selectable_by?(user) : false
  end

  def description_sanitized
    sanitized_description = ActionController::Base.helpers.strip_tags(description).gsub("\n", '').gsub("\r", '').gsub(" ", '').gsub(/^$\n/, '').gsub(/[\u202F\u00A0\u2000\u2001\u2003]/, "")
    errors.add(:description, :too_long, message: 'too long text') if
      sanitized_description.length > Setting[ "extended_option.proposals.description_max_length"].to_i
  end

  protected

    def set_responsible_name
      self.responsible_name = 'unregistriered'
    end
end
