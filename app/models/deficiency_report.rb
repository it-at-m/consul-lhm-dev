class DeficiencyReport < ApplicationRecord

  include Taggable
  include Mappable
  include Imageable
  include Documentable
  include Searchable
  translates :title, touch: true
  translates :description, touch: true
  translates :summary, touch: true
  translates :official_answer, touch: true
  include Globalizable

  acts_as_votable
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  belongs_to :category, class_name: "DeficiencyReport::Category", foreign_key: :deficiency_report_category_id
  belongs_to :status, class_name: "DeficiencyReport::Status", foreign_key: :deficiency_report_status_id
  belongs_to :officer, class_name: "DeficiencyReport::Officer", foreign_key: :deficiency_report_officer_id
  belongs_to :author, -> { with_hidden }, class_name: "User", inverse_of: :deficiency_reports
  has_many :comments, as: :commentable, inverse_of: :commentable, dependent: :destroy

  validates :deficiency_report_category_id, :author, presence: true
  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create
  validates_translation :title, presence: true

  before_save :calculate_hot_score

  scope :sort_by_most_commented,       -> { reorder(comments_count: :desc) }
  scope :sort_by_hot_score,            -> { reorder(hot_score: :desc) }
  scope :sort_by_newest,               -> { reorder(created_at: :desc) }

  def self.search(terms)
    pg_search(terms)
  end

  def searchable_values
    {
      author.username       => "B",
      tag_list.join(" ")    => "B"
    }.merge!(searchable_globalized_values)
  end

  def searchable_translations_definitions
    { title       => "A",
      summary     => "C",
      description => "D" }
  end

  def to_param
    "#{id}-#{title}".parameterize
  end

  def code
    "CONSUL-DF-#{created_at.strftime("%Y-%m")}-#{id}"
  end

  def can_be_published?
    if Setting['deficiency_reports.admins_must_approve_officer_answer'].present?
      official_answer.present? && official_answer_approved?
    else
      official_answer.present?
    end
  end

  def total_votes
    cached_votes_total
  end

  def likes
    cached_votes_up
  end

  def dislikes
    cached_votes_down
	end

  def votes_score
    cached_votes_score
  end

  def votable_by?(user)
    user.present? ? true : false
  end

  def self.deficiency_report_orders
    orders = %w[hot_score newest most_commented]
    orders.delete("hot_score") unless Setting["deficiency_reports.allow_voting"]
    orders
  end

  def register_vote(user, vote_value)
    if votable_by?(user)
      vote_by(voter: user, vote: vote_value)
    end
  end

  def calculate_hot_score
    self.hot_score = ScoreCalculator.hot_score(self)
  end

  def can_be_deleted_by?(user)
    return false if user.nil?
    return true if user.administrator?
    return false if user != author

    official_answer.blank?
  end

end
