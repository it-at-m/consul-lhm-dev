require_dependency Rails.root.join("app", "models", "debate").to_s

class Debate
  include Imageable
  include Documentable

  belongs_to :projekt, optional: true, touch: true
  has_one :debate_phase, through: :projekt
  has_many :geozone_restrictions, through: :debate_phase
  has_many :geozone_affiliations, through: :projekt

  validates :projekt_id, presence: true

  scope :with_current_projekt,  -> { joins(:projekt).merge(Projekt.current) }
  scope :by_author, -> (user_id) {
    return if user_id.nil?

    where(author_id: user_id)
  }

  scope :seen, -> { where.not(ignored_flag_at: nil) }
  scope :unseen, -> { where(ignored_flag_at: nil) }

  alias_attribute :projekt_phase, :debate_phase

  def self.scoped_projekt_ids_for_index
    Projekt.top_level
      .map{ |p| p.all_children_projekts.unshift(p) }
      .flatten.select do |projekt|
        ProjektSetting.find_by( projekt: projekt, key: 'projekt_feature.main.activate').value.present? &&
        ProjektSetting.find_by( projekt: projekt, key: 'projekt_feature.debates.show_in_sidebar_filter').value.present? &&
        projekt.all_children_projekts.unshift(projekt).any? { |p| p.debate_phase.current? || p.debates.any? }
      end
      .pluck(:id)
  end

  def self.scoped_projekt_ids_for_footer(projekt)
    projekt.top_parent.all_children_projekts.unshift(projekt.top_parent).select do |projekt|
      ProjektSetting.find_by( projekt: projekt, key: 'projekt_feature.main.activate').value.present? &&
      projekt.all_children_projekts.unshift(projekt).any? { |p| p.debate_phase.current? || p.debates.any? }
    end.pluck(:id)
  end

  def votable_by?(user)
    user.present? &&
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
      debate_phase.present? && debate_phase.current?
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
