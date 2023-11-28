require_dependency Rails.root.join("app", "controllers", "admin", "poll", "questions_controller").to_s
class Admin::Poll::QuestionsController < Admin::Poll::BaseController
  def order_questions
    ::Poll::Question.order_questions(params[:ordered_list])
    head :ok
  end

  def create
    @question.author = @question.proposal&.author || current_user

    if @question.save
      if @question.parent_question.present?
        redirect_to admin_question_path(@question.parent_question)
      else
        redirect_to admin_question_path(@question)
      end
    else
      render :new
    end
  end

  private

    def question_params
      params.require(:poll_question).permit(
        :poll_id,
        :question,
        :proposal_id,
        :show_hint_callout,
        :show_images,
        :parent_question_id,
        translation_params(Poll::Question),
        votation_type_attributes: [:vote_type, :max_votes]
      )
    end
end
