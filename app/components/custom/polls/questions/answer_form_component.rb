# frozen_string_literal: true

class Polls::Questions::AnswerFormComponent < ApplicationComponent
  attr_reader :question_answer, :user_answer, :question
  delegate :can?, :current_user, :user_signed_in?, to: :helpers

  def initialize(question_answer:, user_answer: nil)
    @question_answer = question_answer
    @user_answer = user_answer
    @question = question_answer.question
  end

  def already_answered?
    user_answer.present?
  end

  def should_show_answer_weight?
    question.votation_type&.multiple_with_weight? &&
      question.max_votes.present?
  end

  def available_vote_weight
    return 0 unless current_user.present?

    if user_answer.present?
      question.max_votes -
        question.answers.where(author_id: current_user.id).sum(:answer_weight) +
        user_answer.answer_weight
    else
      question.max_votes -
        question.answers.where(author_id: current_user.id).sum(:answer_weight)
    end
  end

  def disable_answer?
    return false unless current_user.present?

    (question.votation_type&.multiple? && user_answers.count == question.max_votes) ||
      (question.votation_type&.multiple_with_weight? && available_vote_weight == 0)
  end

  def button_not_answered_class
    if question&.votation_type&.rating_scale?
      "rating-scale-button"
    else
      "button secondary hollow expanded"
    end
  end

  def button_answered_class
    if question&.votation_type&.rating_scale?
      "rating-scale-button rating-scale-button--answered"
    else
      "button answered expanded"
    end
  end

  private

    def user_answers
      @user_answers ||= question.answers.by_author(current_user)
    end
end
