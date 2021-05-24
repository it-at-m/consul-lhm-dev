require_dependency Rails.root.join("app", "models", "debate").to_s

class Debate
  include Imageable

  belongs_to :projekt, optional: true
  has_one :debate_phase, through: :projekt
  has_many :geozones, through: :debate_phase

  validates :projekt_id, presence: true, if: :require_a_projekt?

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
      debate_phase && debate_phase.geozones.blank? ||
      (debate_phase && debate_phase.geozones.any? && debate_phase.geozones.include?(user.geozone) )
    ) &&
    (
      projekt.blank? ||
      debate_phase && !debate_phase.expired?
    )

    #  user.voted_for?(self)
  end


end
