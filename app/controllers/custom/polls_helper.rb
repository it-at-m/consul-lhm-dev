require_dependency Rails.root.join("app", "helpers", "polls_helper").to_s

module PollsHelper
  def any_answer_with_image?(question)
    question.question_answers.any? { |answer| answer.images.any? }
  end

  def answer_with_description?(answer)
    answer.description.present? || answer.images.any? || answer.documents.present? || answer.videos.present?
  end

  def can_answer_be_open?(question)
    question.question_answers.pluck(:open_answer).count(true) < 1
  end
end
