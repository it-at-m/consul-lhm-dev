class Polls::Questions::AnswersController < ApplicationController
  before_action :set_poll, :set_question_answer, :question
  respond_to :js

  def stats
    authorize! :stats, @poll
  end

  def results
    authorize! :results, @poll
  end

  private

    def set_poll
      @poll = Poll.find(params[:poll_id])
    end

    def set_question_answer
      @question_answer = Poll::Question::Answer.find(params[:id])
    end

    def question
      @question = @question_answer.question
    end
end
