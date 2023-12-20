module AdminActions::Poll::Questions::Answers::Documents
  extend ActiveSupport::Concern

  include DocumentAttributes

  included do
    load_and_authorize_resource :answer, class: "::Poll::Question::Answer"
  end

  def index
    render "admin/poll/questions/answers/documents/index"
  end

  def create
    @answer.attributes = documents_params
    authorize! :update, @answer

    if @answer.save
      redirect_to polymorphic_path([@namespace, @answer, :documents]),
        notice: t("admin.documents.create.success_notice")
    else
      render "admin/poll/questions/answers/documents/index"
    end
  end

  private

    def documents_params
      params.require(:poll_question_answer).permit(allowed_params)
    end

    def allowed_params
      [documents_attributes: document_attributes]
    end
end
