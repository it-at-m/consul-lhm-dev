# frozen_string_literal: true

class ProjektQuestions::ProjektQuestionComponent < ApplicationComponent
  attr_reader :projekt_question, :projekt, :projekt_question_answer, :comment_tree

  def initialize(projekt_question, projekt_question_answer:)
    @projekt_question = projekt_question
    @projekt_question_answer = projekt_question_answer
    @projekt = projekt_question.projekt
    @current_comment_order = "oldest"
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
