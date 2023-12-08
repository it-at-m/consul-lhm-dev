module AdminActions::Poll::Questions
  extend ActiveSupport::Concern

  include CommentableActions
  include Translatable

  included do
    load_and_authorize_resource :poll
    load_resource class: "Poll::Question", except: [:order_questions]
    authorize_resource except: [:new, :create, :order_questions]
    skip_authorization_check only: :new
  end

  def index
    @polls = Poll.not_budget
    @questions = @questions.search(search_params).page(params[:page]).order("created_at DESC")

    @proposals = Proposal.successful.sort_by_confidence_score

    render "admin/poll/questions/index"
  end

  def new
    proposal = Proposal.find(params[:proposal_id]) if params[:proposal_id].present?
    @question.copy_attributes_from_proposal(proposal)
    @question.poll = @poll
    @question.votation_type = VotationType.new

    render "admin/poll/questions/new"
  end

  def create
    @question.author = @question.proposal&.author || current_user
    authorize! :create, @question

    if @question.save
      redirect_to polymorphic_path([@namespace, @question])
    else
      render "admin/poll/questions/new"
    end
  end

  def show
    render "admin/poll/questions/show"
  end

  def edit
    render "admin/poll/questions/edit"
  end

  def update
    if @question.update(question_params)
      redirect_to polymorphic_path([@namespace, @question]), notice: t("flash.actions.save_changes.notice")
    else
      render "admin/poll/questions/edit"
    end
  end

  def destroy
    @question.destroy!
    redirect_to polymorphic_path([@namespace, @question.poll]), notice: t("admin.questions.destroy.notice")
  end

  def order_questions # custom
    ::Poll::Question.order_questions(params[:ordered_list])
    head :ok
  end

  private

    def question_params
      params.require(:poll_question).permit(
        :poll_id,
        :question,
        :proposal_id,
        :show_hint_callout,
        :show_images,
        translation_params(Poll::Question),
        votation_type_attributes: [:vote_type, :max_votes]
      )
    end

    def search_params
      params.permit(:poll_id, :search)
    end
end
