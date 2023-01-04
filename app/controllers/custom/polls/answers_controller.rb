require_dependency Rails.root.join("app", "controllers", "polls", "answers_controller").to_s

class Polls::AnswersController < ApplicationController
  def destroy
    updated_weight = params["answer_weight_poll_answer_#{@answer.id}"].to_i

    if @question.vote_type == "multiple_with_weight" &&
         updated_weight > 0 &&
         params[:button] != "remove_answer"
      answer = @question.find_or_initialize_user_answer(current_user, @answer.answer)
      answer.answer_weight = updated_weight
      answer.save_and_record_voter_participation

    else
      @answer.destroy_and_remove_voter_participation
      @answer_updated = "unanswered" #custom line

    end

    render "polls/questions/answers"
  end
end
