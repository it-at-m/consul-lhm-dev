require_dependency Rails.root.join("app", "models", "poll", "question").to_s

class Poll::Question < ApplicationRecord
  translates :description, :min_rating_scale_label, :max_rating_scale_label, touch: true

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

  def self.model_name
    mname = super
    mname.instance_variable_set(:@route_key, "questions")
    mname.instance_variable_set(:@singular_route_key, "question")
    mname
  end
end
