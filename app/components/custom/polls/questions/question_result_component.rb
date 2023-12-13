class Polls::Questions::QuestionResultComponent < ApplicationComponent
  attr_reader :question

  def initialize(question:)
    @question = question
  end

  private

    def additional_class
      if @question.parent_question_id.present?
        "-nested"
      elsif @question.bundle_question?
        "-bundle-question"
      end
    end
end
