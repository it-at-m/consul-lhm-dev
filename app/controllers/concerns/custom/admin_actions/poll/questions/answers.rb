module AdminActions::Poll::Questions::Answers
  extend ActiveSupport::Concern

  include Translatable
  include DocumentAttributes

  included do
    before_action :load_answer, only: [:show, :edit, :update, :documents]
    load_and_authorize_resource :question, class: "::Poll::Question"
  end

  def new
    @answer = ::Poll::Question::Answer.new
    @question = ::Poll::Question.find_by(id: params[:question_id])

    render "admin/poll/questions/answers/new"
  end

  def create
    @answer = ::Poll::Question::Answer.new(answer_params)
    @question = @answer.question

    if @answer.save
      redirect_to polymorphic_path([@namespace, @question]),
               notice: t("flash.actions.create.poll_question_answer")
    else
      render "admin/poll/questions/answers/new"
    end
  end

  def show
    render "admin/poll/questions/answers/show"
  end

  def edit
    @question = @answer.question

    render "admin/poll/questions/answers/edit"
  end

  def update
    if @answer.update(answer_params)
      redirect_to polymorphic_path([@namespace, @answer.question]),
               notice: t("flash.actions.save_changes.notice")
    else
      render "admin/poll/questions/answers/edit"
    end
  end

  def destroy
    load_answer
    if @answer.question.poll.safe_to_delete_answer?
      @answer.destroy!
      redirect_to polymorphic_path([@namespace, @answer.question]), notice: t("custom.admin.polls.questions.answers.notice.delete.success")
    else
      redirect_to polymorphic_path([@namespace, @answer.question]), flash: { error: t("custom.admin.polls.questions.answers.notice.delete.error") }
    end
  end

  def documents
    @documents = @answer.documents

    render "admin/poll/questions/answers/documents"
  end

  def order_answers
    ::Poll::Question::Answer.order_answers(params[:ordered_list])
    head :ok
  end

  private

    def answer_params
      attributes = [
        :title, :description, :given_order, :question_id, :open_answer, :more_info_link,
        :next_question_id, documents_attributes: document_attributes]

      params.require(:poll_question_answer).permit(
        *attributes, translation_params(Poll::Question::Answer)
      )
    end

    def load_answer
      @answer = ::Poll::Question::Answer.find(params[:id] || params[:answer_id])
    end

    def resource
      load_answer unless @answer
      @answer
    end
end
