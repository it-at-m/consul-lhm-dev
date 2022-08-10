# frozen_string_literal: true

class ProjektQuestions::ProjektQuestionComponent < ApplicationComponent
  attr_reader :projekt_question, :projekt, :projekt_question_answer

  def initialize(projekt_question, projekt_question_answer:, comment_tree: nil)
    @projekt_question = projekt_question
    @projekt_question_answer = projekt_question_answer
    @comment_tree = comment_tree
    @projekt = projekt_question.projekt
  end
end
