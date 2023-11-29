require_dependency Rails.root.join("app", "controllers", "admin", "poll", "questions_controller").to_s
class Admin::Poll::QuestionsController < Admin::Poll::BaseController
  def order_questions
    ::Poll::Question.order_questions(params[:ordered_list])
    head :ok
  end

  def new
    proposal = Proposal.find(params[:proposal_id]) if params[:proposal_id].present?
    @question.copy_attributes_from_proposal(proposal)
    @question.poll = @poll
    @question.votation_type = VotationType.new

    authorize! :create, @question
  end

  def create
    @question.author = @question.proposal&.author || current_user

    if @question.votation_type.nil?
      @question.votation_type = VotationType.new(vote_type: :unique)
    end

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

  def destroy
    @question.destroy!

    destroy_path =
      if @question.parent_question.present?
        admin_question_path(@question.parent_question)
      else
        admin_poll_path(@question.poll)
      end

    redirect_to destroy_path, notice: t("admin.questions.destroy.notice")
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
        :bundle_question,
        translation_params(Poll::Question),
        votation_type_attributes: [:vote_type, :max_votes]
      )
    end
end
