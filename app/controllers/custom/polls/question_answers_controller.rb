class Polls::QuestionAnswersController < ApplicationController
  skip_authorization_check #debugger

  def results
    @poll = Poll.find(params[:poll_id])
    @question_answer = Poll::Question::Answer.find(params[:id])
    @question = @question_answer.question
  end
end
