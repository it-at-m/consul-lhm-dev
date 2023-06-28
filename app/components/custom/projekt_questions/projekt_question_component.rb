# frozen_string_literal: true

class ProjektQuestions::ProjektQuestionComponent < ApplicationComponent
  attr_reader :projekt_question, :projekt, :projekt_phase, :projekt_question_answer, :comment_tree

  def initialize(projekt_question, projekt_question_answer:)
    @projekt_question = projekt_question
    @projekt_question_answer = projekt_question_answer
    @projekt_phase = projekt_question.projekt_phase
    @projekt = projekt_phase.projekt
    @current_comment_order = "newest"
  end

  def before_render
    comment_variables =
      helpers
       .set_comments_view_context_variables(
         @projekt_question,
         comment_order: @current_comment_order
       )

    @comment_tree = comment_variables[:comment_tree]
  end
end
