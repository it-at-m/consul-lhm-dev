require_dependency Rails.root.join("app", "models", "poll", "question", "answer").to_s

class Poll::Question::Answer < ApplicationRecord
  def all_open_answers
    return nil unless self.open_answer
    Poll::Answer.where(question_id: question, answer: title).where.not(open_answer_text: nil)
  end

  def total_votes
    Poll::Answer.where(question_id: question, answer: title).sum(:answer_weight) +
      ::Poll::PartialResult.where(question: question).where(answer: title).sum(:amount)
  end

  def total_votes_percentage
    question.answers_total_votes.zero? ? 0 : (total_votes * 100.0) / question.answers_total_votes
  end

  def total_connected_votes_to(other_answer)
    answered_other_question_user_ids = Poll::Answer.where(question_id: other_answer.question, answer: other_answer.title).pluck(:author_id)
    Poll::Answer.where(question_id: question, answer: title, author_id: answered_other_question_user_ids).sum(:answer_weight)
  end

  def total_connected_votes_percentage(other_answer)
    question.answers_total_votes.zero? ? 0 : (total_connected_votes_to(other_answer) * 100.0) / question.answers_total_votes
  end
end
