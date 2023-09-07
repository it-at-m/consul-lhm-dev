# frozen_string_literal: true

class Polls::Questions::RegularAnswersComponent < Polls::Questions::AnswersComponent
  def question_answers
    question.question_answers.where.not(open_answer: true)
  end
end
