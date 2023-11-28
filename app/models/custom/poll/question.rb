require_dependency Rails.root.join("app", "models", "poll", "question").to_s

class Poll::Question < ApplicationRecord
  translates :description, :min_rating_scale_label, :max_rating_scale_label, touch: true
  has_many :nested_questions, class_name: "Poll::Question", dependent: :destroy, foreign_key: :parent_question_id
  belongs_to :parent_question, class_name: "Poll::Question", optional: true

  validate :validate_parent_question_id

  scope :root_questions, -> {
    where(parent_question_id: nil)
  }

  def self.order_questions(ordered_array)
    ordered_array.each_with_index do |question_id, order|
      find(question_id).update_column(:given_order, (order + 1))
    end
  end

  def open_question_answer
    question_answers.where(open_answer: true).last
  end

  def allows_multiple_answers?
    VotationType.allowing_multiple_answers.include?(votation_type.vote_type)
  end

  def validate_parent_question_id
    if parent_question_id.present?
      question_ids = poll.questions.ids

      if question_ids.exclude?(parent_question_id)
        errors.add(:base, "Parent question doesn't belong to the same poll")
      end
    end
  end
end
