require_dependency Rails.root.join("app", "models", "poll", "question").to_s
class Poll::Question < ApplicationRecord

  def self.order_questions(ordered_array)
    ordered_array.each_with_index do |question_id, order|
      find(question_id).update_column(:given_order, (order + 1))
    end
  end

  def open_question_answer
    question_answers.where(open_answer: true).last
  end
end
