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

  def link_to_poll_with_block(poll, &block)
    if can?(:results, poll)
      link_to(results_poll_path(id: poll.slug || poll.id), data: { turbolinks: false }, &block)
    elsif can?(:stats, poll)
      link_to(stats_poll_path(id: poll.slug || poll.id), &block)
    else
      link_to(poll_path(id: poll.slug || poll.id), &block)
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

  def cannot_answer_callout_text(permission_problem_key, voting_phase)
    return nil if permission_problem_key.blank?

    if permission_problem_key == :not_logged_in
      sanitize(t("custom.projekt_phases.permission_problem.poll_votes.#{permission_problem_key}",
               sign_in: link_to_signin, sign_up: link_to_signup))

    else
      sanitize(t("custom.projekt_phases.permission_problem.poll_votes.#{permission_problem_key}",
               verify: link_to_verify_account,
               city: Setting["org_name"],
               geozones: voting_phase.geozone_restrictions_formatted,
               age_restriction: voting_phase.age_restriction_formatted,
               restricted_streets: voting_phase.street_restrictions_formatted
              ))
    end
  end

  def cannot_answer_callout_class(permission_problem_key)
    return "primary" if permission_problem_key == :not_logged_in

    "warning"
  end
end
