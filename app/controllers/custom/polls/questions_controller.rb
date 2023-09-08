require_dependency Rails.root.join("app", "controllers", "polls", "questions_controller").to_s

class Polls::QuestionsController < ApplicationController
  def answer
    answer = @question.find_or_initialize_user_answer(current_user, params[:answer])
    answer.answer_weight = params[:answer_weight].presence || 1
    answer.save_and_record_voter_participation

    unless providing_an_open_answer?(answer)
      @answer_updated = "answered"
    end

    render "polls/questions/answers"
  end

  def update_open_answer
    answer = @question.find_or_initialize_user_answer(current_user, open_answer_params[:answer])
    answer.save_and_record_voter_participation if answer.new_record?

    if answer.update(open_answer_text: open_answer_params[:open_answer_text])
      @open_answer_updated = true
    end
    render "polls/questions/answers"
  end

  def csv_answers_streets
    question = Poll::Question.find(params[:id])

    respond_to do |format|
      format.csv do
        send_data CsvServices::PollQuestionAnswersStreetsExporter.new(question).call,
          filename: "question_#{question.id}_answers_streets_#{Time.zone.today.strftime("%d/%m/%Y")}.csv"
      end
    end
  end

  def csv_answers_votes
    question = Poll::Question.find(params[:id])

    respond_to do |format|
      format.csv do
        send_data CsvServices::PollQuestionAnswersVotesExporter.new(question).call,
          filename: "question_#{question.id}_answers_votes_#{Time.zone.today.strftime("%d/%m/%Y")}.csv"
      end
    end
  end

  private

    def open_answer_params
      params.require(:poll_answer).permit(:answer, :open_answer_text)
    end

    def providing_an_open_answer?(answer)
      @question.open_question_answer.present? && @question.open_question_answer.title == answer.answer
    end
end
