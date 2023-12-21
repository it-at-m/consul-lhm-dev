# frozen_string_literal: true

class Polls::Questions::OpenAnswerComponent < ApplicationComponent
  attr_reader :question
  delegate :can?, :current_user, to: :helpers

  def initialize(question)
    @question = question
  end

  def render?
    question.open_question_answer.present?
  end

  def can_answer?
    # question.open_question_answer.present? && already_answered?(question.open_question_answer)
    can?(:answer, question) &&
      question.open_question_answer.present?
  end

  def open_answer
    @open_answer ||= question.answers.find_or_initialize_by(author: current_user, answer: question.open_question_answer.title)
  end

  def additional_form_class
    if open_answer.open_answer_text.present?
      "js-question-answered"
    end
  end
end
