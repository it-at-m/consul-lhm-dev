require_dependency Rails.root.join("app", "models", "poll", "question").to_s
class Poll::Question < ApplicationRecord
  def open_question_answer
    question_answers.where(open_answer: true).last
  end
end
