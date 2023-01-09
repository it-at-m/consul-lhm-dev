class Polls::QuestionAnswersController < ApplicationController

  def results
    @poll = Poll.find(params[:poll_id])
    @question_answer = Poll::Question::Answer.find(params[:id])
    debugger
  end
end
