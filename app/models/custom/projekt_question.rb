class ProjektQuestion < ApplicationRecord
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases
  include Notifiable

  translates :title, touch: true
  include Globalizable

  belongs_to :author, -> { with_hidden }, class_name: "User", inverse_of: :projekt_questions
  belongs_to :projekt
  belongs_to :projekt_livestream, optional: true

  has_many :question_options, -> { order(:id) },
            class_name: "ProjektQuestionOption",
            foreign_key: "projekt_question_id",
            dependent: :destroy
  has_many(
    :answers,
    class_name: "ProjektQuestionAnswer",
    foreign_key: "projekt_question_id",
    dependent: :destroy
  )
  has_many :comments, as: :commentable, inverse_of: :commentable, dependent: :destroy

  accepts_nested_attributes_for :question_options, reject_if: proc { |attributes| attributes.all? { |k, v| v.blank? } }, allow_destroy: true

  validates :projekt, presence: true
  validates_translation :title, presence: true

  scope :sorted, -> { order("id ASC") }

  scope :root_questions, -> {
    where(projekt_livestream_id: nil)
  }

  scope :livestream_questions, -> {
    where.not(projekt_livestream_id: nil)
  }

  def self.base_selection(scoped_projekt_ids = Projekt.ids)
    where(projekt_id: scoped_projekt_ids)
  end

  def root_question?
    projekt_livestream_id.nil?
  end

  def livestream_question?
    projekt_livestream_id.present?
  end

  def base_query_for_navigation
    base_query = projekt.questions.sorted

    if root_question?
      base_query.root_questions
    elsif livestream_question?
      base_query.where(projekt_livestream_id: projekt_livestream_id)
    end
  end

  def sibling_questions
    if root_question?
      projekt.questions.root_questions
    elsif projekt_livestream.present?
      projekt_livestream.projekt_questions
    end
  end

  def next_question_id
    return @next_question_id if @next_question_id.present?

    @next_question_id ||= next_questions.ids.first
  end

  def next_questions
    base_query_for_navigation.where("id > ?", id)
  end

  def previous_question_id
    @previous_question_id ||= base_query_for_navigation.where("id < ?", id).ids.last
  end

  def first_question_id
    @first_question_id ||= base_query_for_navigation.ids.first
  end

  def most_recent_question_id
    @most_recent_question_id ||= base_query_for_navigation.ids.last
  end

  def answer_for_user(user)
    answers.find_by(user: user)
  end

  def comments_allowed?(current_user)
    !comments_not_allowed?(current_user)
  end

  def comments_not_allowed?(current_user)
    return true if comments_closed?
    return true if current_user.nil?
    return true if current_user.unverified?
    return true if current_user.organization?

    if root_question?
      (
        projekt.question_phase.particapation_closed? ||
        projekt.question_phase.geozone_restricted == "only_citizens" && current_user.not_current_city_citizen? ||
        projekt.question_phase.geozone_restricted == "only_geozones" && !projekt.question_phase.geozone_restrictions.include?(current_user&.geozone) ||
        projekt.question_phase.expired? ||
        projekt.question_phase.not_current? ||
        projekt.question_phase.not_active?
      )
    else
      true
    end
  end

  def comments_closed?
    !comments_open?
  end

  def comments_open?
    projekt.question_phase.phase_activated?
  end

  def best_comments
    comments.sort_by_supports.limit(3)
  end

  def answers_count
    question_options.sum(&:answers_count)
  end
end
