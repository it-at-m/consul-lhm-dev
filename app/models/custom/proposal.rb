require_dependency Rails.root.join("app", "models", "proposal").to_s
class Proposal < ApplicationRecord

  belongs_to :projekt, optional: true
  has_one :proposal_phase, through: :projekt
  has_many :geozone_restrictions, through: :proposal_phase
  has_many :geozone_affiliations, through: :projekt

  validates :projekt_id, presence: true, if: :require_a_projekt?
  validate :description_sanitized

  def require_a_projekt?
    Setting["projekts.connected_resources"].present? ? true : false
  end

  def votable_by?(user)
      user &&
      !user.organization? &&
      user.level_two_or_three_verified? &&
      (
        Setting['feature.user.skip_verification'].present? ||
        projekt.blank? ||
        proposal_phase && proposal_phase.geozone_restrictions.blank? ||
        (proposal_phase && proposal_phase.geozone_restrictions.any? && proposal_phase.geozone_restrictions.include?(user.geozone) )
      ) &&
      (
        projekt.blank? ||
        proposal_phase && !proposal_phase.expired?
      )
  end

  def description_sanitized
    sanitized_description = ActionController::Base.helpers.strip_tags(description).gsub("\n", '').gsub("\r", '').gsub(" ", '').gsub(/^$\n/, '').gsub(/[\u202F\u00A0\u2000\u2001\u2003]/, "")
    errors.add(:description, :too_long, message: 'too long text') if
      sanitized_description.length > Setting[ "extended_option.proposals.description_max_length"].to_i
  end
end
