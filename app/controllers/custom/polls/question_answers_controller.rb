class Polls::QuestionAnswersController < ApplicationController
  respond_to :js

  def results
    @poll = Poll.find(params[:poll_id])
    @question_answer = Poll::Question::Answer.find(params[:id])
    @question = @question_answer.question

    authorize! :results, @poll
  end
end
