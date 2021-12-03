require_dependency Rails.root.join("app", "models", "debate").to_s

class Debate
  include Imageable

  belongs_to :projekt, optional: true
  has_one :debate_phase, through: :projekt
  has_many :geozone_restrictions, through: :debate_phase
  has_many :geozone_affiliations, through: :projekt

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
      debate_phase && debate_phase.geozone_restrictions.blank? ||
      (debate_phase && debate_phase.geozone_restrictions.any? && debate_phase.geozone_restrictions.include?(user.geozone) )
    ) &&
    (
      projekt.blank? ||
      debate_phase && !debate_phase.expired?
    )

    #  user.voted_for?(self)
  end

  def comments_allowed?(user)
    projekt.present? ? debate_phase.selectable_by?(user) : false
  end

  def register_vote(user, vote_value)
    send("process_#{vote_value}_vote", user) if votable_by?(user)
  end

  def process_yes_vote(user)
    if user.voted_up_for?(self)
      unliked_by user
      Debate.decrement_counter(:cached_anonymous_votes_total, id) if user.unverified?
    else
      liked_by user
      Debate.increment_counter(:cached_anonymous_votes_total, id) if user.unverified?
    end
  end

  def process_no_vote(user)
    if user.voted_down_for?(self)
      undisliked_by user
      Debate.decrement_counter(:cached_anonymous_votes_total, id) if user.unverified?
    else
      disliked_by user
      Debate.increment_counter(:cached_anonymous_votes_total, id) if user.unverified?
    end
  end
end
