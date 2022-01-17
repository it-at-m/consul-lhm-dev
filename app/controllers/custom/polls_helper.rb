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

  def link_to_poll(text, poll)
    if can?(:results, poll)
      link_to text, results_poll_path(id: poll.slug || poll.id), data: { turbolinks: false }
    elsif can?(:stats, poll)
      link_to text, stats_poll_path(id: poll.slug || poll.id)
    else
      link_to text, poll_path(id: poll.slug || poll.id)
    end
  end

  def poll_remaining_activity_days(poll)
    remaining_days = (poll.ends_at.to_date - Date.today).to_i

    if remaining_days > 0
      t("custom.polls.poll.days_left", count: (@poll.ends_at.to_date - Date.today).to_i )
    elsif remaining_days == 0
      t("custom.polls.poll.expires_today")
    else
      t("custom.polls.poll.expired")
    end
  end
end
