class DeficiencyReport < ApplicationRecord
  include Taggable
  include Mappable
  include Imageable
  include Documentable
  include Searchable
  include OnBehalfOfSubmittable
  translates :title, touch: true
  translates :description, touch: true
  translates :summary, touch: true
  translates :official_answer, touch: true
  include Globalizable

  acts_as_votable
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  audited on: [:update, :destroy]
  has_associated_audits
  translation_class.class_eval do
    audited associated_with: :globalized_model,
            only: DeficiencyReport.translated_attribute_names
  end

  belongs_to :category, class_name: "DeficiencyReport::Category", foreign_key: :deficiency_report_category_id
  belongs_to :status, class_name: "DeficiencyReport::Status", foreign_key: :deficiency_report_status_id
  belongs_to :officer, class_name: "DeficiencyReport::Officer", foreign_key: :deficiency_report_officer_id
  belongs_to :area, class_name: "DeficiencyReport::Area",
    foreign_key: :deficiency_report_area_id, inverse_of: :deficiency_reports
  belongs_to :author, -> { with_hidden }, class_name: "User", inverse_of: :deficiency_reports
  has_many :comments, as: :commentable, inverse_of: :commentable, dependent: :destroy

  validates :deficiency_report_category_id, :author, presence: true
  validates :deficiency_report_area_id, presence: true, if: -> { validate_area_presence? }

  # validates :terms_of_service, acceptance: { allow_nil: false }, on: :create #custom
  validates :resource_terms, acceptance: { allow_nil: false }, on: :create #custom

  validates_translation :title, presence: true

  before_save :calculate_hot_score

  scope :sort_by_most_commented,       -> { reorder(comments_count: :desc) }
  scope :sort_by_hot_score,            -> { reorder(hot_score: :desc) }
  scope :sort_by_newest,               -> { reorder(created_at: :desc) }
  scope :by_author, ->(user_id) {
    return if user_id.nil?

    where(author_id: user_id)
  }

  def audited_changes
    if super.has_key?("deficiency_report_status_id")
      old_status_title = DeficiencyReport::Status.find_by(id: deficiency_report_status_id_was)&.title
      super.merge!("deficiency_report_status_id" => [old_status_title, status.title])
    elsif super.has_key?("deficiency_report_officer_id")
      old_officer_name = DeficiencyReport::Officer.find_by(id: deficiency_report_officer_id_was)&.name
      super.merge!("deficiency_report_officer_id" => [old_officer_name, officer.name])
    elsif super.has_key?("deficiency_report_category_id")
      old_category_name = DeficiencyReport::Category.find_by(id: deficiency_report_category_id_was)&.name
      super.merge!("deficiency_report_category_id" => [old_category_name, category.name])
    else
      super
    end
  end

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
    if Setting["deficiency_reports.admins_must_approve_officer_answer"].present?
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
    user.present?
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

  def comments_allowed?(user)
    true
  end

  private

    def validate_area_presence?
      DeficiencyReport::Area.exists?
    end
end
