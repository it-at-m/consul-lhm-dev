require_dependency Rails.root.join("app", "models", "poll", "question", "answer").to_s

class Poll::Question::Answer < ApplicationRecord
  def all_open_answers
    return nil unless self.open_answer
    Poll::Answer.where(question_id: question, answer: title)
  end
end
