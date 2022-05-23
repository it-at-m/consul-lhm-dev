require_dependency Rails.root.join("app", "controllers", "polls", "questions_controller").to_s

class Polls::QuestionsController < ApplicationController

  def answer
    @poll = @question.poll

    answer = @question.answers.find_or_initialize_by(author: current_user, answer: params[:answer])
    answer.save_and_record_voter_participation(params[:token])

    if !@question.multiple
      @question.answers.where(author: current_user).where.not(answer: params[:answer]).delete_all
    end

    unless providing_an_open_answer?(answer)
      @answer_updated = 'answered'
    end

    @answers_by_question_id = { @question.id => @question.answers.where(author: current_user).map { |answer| answer.answer } }
  end

  def unanswer
    @poll = @question.poll

    answer = @question.answers.find_or_initialize_by(author: current_user, answer: params[:answer])

    @question.answers.where(author: current_user, answer: params[:answer]).delete_all
    @question.poll.delete_voter_participation_if_no_votes(current_user, params[:token])

    unless providing_an_open_answer?(answer)
      @answer_updated = 'unanswered'
    end

    @answers_by_question_id = { @question.id => @question.answers.where(author: current_user).map { |answer| answer.answer } }
  end

  def update_open_answer
    answer = @question.answers.find_or_initialize_by(author: current_user, answer: open_answer_params[:answer])
    if answer.update(open_answer_text: open_answer_params[:open_answer_text])
      @open_answer_updated = true
    end
    @answers_by_question_id = { @question.id => @question.answers.where(author: current_user).map { |answer| answer.answer } }
    render :answer
  end

  private

  def open_answer_params
    params.require(:poll_answer).permit(:answer, :open_answer_text)
	end

  def providing_an_open_answer?(answer)
    @question.open_question_answer.present? && @question.open_question_answer.title == answer.answer
  end
end
