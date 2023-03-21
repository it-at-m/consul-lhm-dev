require_dependency Rails.root.join("app", "models", "debate").to_s

class Debate
  include Imageable
  include Documentable
  include Labelable

  belongs_to :projekt, optional: true, touch: true
  has_one :debate_phase, through: :projekt
  has_many :geozone_restrictions, through: :debate_phase
  has_many :geozone_affiliations, through: :projekt

  delegate :votable_by?, to: :debate_phase
  delegate :comments_allowed?, to: :debate_phase

  validates :projekt_id, presence: true

  # validates :terms_of_service, acceptance: { allow_nil: false }, on: :create
  validates :terms_data_storage, acceptance: { allow_nil: false }, on: :create #custom
  validates :terms_data_protection, acceptance: { allow_nil: false }, on: :create #custom
  validates :terms_general, acceptance: { allow_nil: false }, on: :create #custom

  scope :with_current_projekt, -> { joins(:projekt).merge(Projekt.current) }
  scope :by_author, ->(user_id) {
    return if user_id.nil?

    where(author_id: user_id)
  }

  scope :sort_by_alphabet, -> {
    with_translations(I18n.locale).
    select("debates.*, LOWER(debate_translations.title)").
    reorder("LOWER(debate_translations.title) ASC")
  }
  scope :sort_by_votes_total, -> { reorder(cached_votes_total: :desc) }

  scope :seen, -> { where.not(ignored_flag_at: nil) }
  scope :unseen, -> { where(ignored_flag_at: nil) }

  alias_attribute :projekt_phase, :debate_phase

  def self.debates_orders(user = nil)
    orders = %w[hot_score created_at alphabet votes_total random]
    # orders << "recommendations" if Setting["feature.user.recommendations_on_debates"] && user&.recommended_debates
    orders
  end

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

  def votes_score
    cached_votes_up + cached_votes_down
  end
end
