require_dependency Rails.root.join("app", "components", "polls", "questions", "answers_component").to_s

class Polls::Questions::AnswersComponent < ApplicationComponent
  delegate :projekt_feature?, :projekt_phase_feature?, :answer_with_description?, to: :helpers

  def initialize(question, answer_updated: nil, open_answer_updated: nil)
    @question = question
    @answer_updated = answer_updated
    @open_answer_updated = open_answer_updated
  end

  def poll_question_answers_class
    classes = ["poll-question-answers"]

    if question.votation_type.rating_scale?
      classes.push("rating-scale")

      count_of_rating_scale_cells = question.question_answers.count
      count_of_rating_scale_cells += 1 if question.min_rating_scale_label.present?
      count_of_rating_scale_cells += 1 if question.max_rating_scale_label.present?
      classes.push("rating-scale-#{count_of_rating_scale_cells}-answers")
    end

    classes.join(" ")
  end

  def poll_answer_group_class
    classes = ["poll-answer-group"]

    if show_additional_info_images?
      classes.push("align-answers-top image-answers")
    end

    classes.join(" ")
  end

  def button_not_answered_class
    if question.votation_type.rating_scale?
      "rating-scale-button"
    else
      "button secondary hollow expanded"
    end
  end

  def button_answered_class
    if question.votation_type.rating_scale?
      "rating-scale-button rating-scale-button--answered"
    else
      "button answered expanded"
    end
  end

  def show_additional_info_images?
    return if question.votation_type.rating_scale?

    projekt_phase_feature?(question.poll&.projekt_phase, "resource.additional_info_for_each_answer") &&
      question.show_images?
  end

  def show_additional_info_description?(question_answer)
    return if question.votation_type.rating_scale?

    projekt_phase_feature?(question.poll&.projekt_phase, "resource.additional_info_for_each_answer") &&
      answer_with_description?(question_answer)
  end

  def should_show_answer_weight?
    question.votation_type.multiple_with_weight? &&
      question.max_votes.present?
  end

  def available_vote_weight(question_answer)
    return 0 unless current_user.present?

    if user_answer(question_answer).present?
      question.max_votes -
        question.answers.where(author_id: current_user.id).sum(:answer_weight) +
        user_answer(question_answer).answer_weight
    else
      question.max_votes -
        question.answers.where(author_id: current_user.id).sum(:answer_weight)
    end
  end

  def disable_answer?(question_answer)
    return false unless current_user.present?

    (question.votation_type.multiple? && user_answers.count == question.max_votes) ||
      (question.votation_type.multiple_with_weight? && available_vote_weight(question_answer) == 0)
  end
end
