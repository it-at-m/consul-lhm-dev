class ProjektQuestion < ApplicationRecord
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases
  include Notifiable

  translates :title, touch: true
  include Globalizable

  belongs_to :author, -> { with_hidden }, class_name: "User", inverse_of: :projekt_questions
  # belongs_to :projekt, foreign_key: "projekt_question_id", inverse_of: :questions
  belongs_to :projekt

  has_many :question_options, -> { order(:id) }, class_name: "ProjektQuestionOption", foreign_key: "projekt_question_id",
                                                 dependent: :destroy #, inverse_of: :question
  has_many :answers, class_name: "ProjektQuestionAnswer", foreign_key: "projekt_question_id", dependent: :destroy #, inverse_of: :question
  has_many :comments, as: :commentable, inverse_of: :commentable, dependent: :destroy

  accepts_nested_attributes_for :question_options, reject_if: proc { |attributes| attributes.all? { |k, v| v.blank? } }, allow_destroy: true

  validates :projekt, presence: true
  validates_translation :title, presence: true

  scope :sorted, -> { order("id ASC") }

  def self.base_selection(scoped_projekt_ids = Projekt.ids)
    where(projekt_id: scoped_projekt_ids)
  end

  def next_question_id
    @next_question_id ||= projekt.questions.where("id > ?", id).sorted.limit(1).ids.first
  end

  def previous_question_id
    @previous_question_id ||= projekt.questions.where("id < ?", id).sorted.ids.last
  end

  def first_question_id
    @first_question_id ||= projekt.questions.sorted.limit(1).ids.first
  end

  def answer_for_user(user)
    answers.find_by(user: user)
  end

  def comments_for_verified_residents_only?
    true
  end

  def comments_closed?
    !comments_open?
  end

  def comments_open?
    projekt.question_phase.active?
  end

  def best_comments
    comments.sort_by_supports.limit(3)
  end

  def answers_count
    question_options.sum(&:answers_count)
  end
end
