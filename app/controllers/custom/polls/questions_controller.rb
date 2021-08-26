require_dependency Rails.root.join("app", "controllers", "polls", "questions_controller").to_s

class Polls::QuestionsController < ApplicationController

  def update_open_answer
    answer = @question.answers.find_or_initialize_by(author: current_user, answer: open_answer_params[:answer])
    if answer.update(open_answer_text: open_answer_params[:open_answer_text])
      @answer_updated = true
    end
    @answers_by_question_id = { @question.id => @question.answers.where(author: current_user).map { |answer| answer.answer } }
    render :answer
  end

  private

  def open_answer_params
    params.require(:poll_answer).permit(:answer, :open_answer_text)
	end
end
