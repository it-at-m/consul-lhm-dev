module AdminActions::Poll::Questions::Answers::Images
  extend ActiveSupport::Concern

  include ImageAttributes

  included do
    # before_action :load_answer, except: :destroy
    load_and_authorize_resource :answer, class: "::Poll::Question::Answer"
  end

  def index
    render "admin/poll/questions/answers/images/index"
  end

  def new
    render "admin/poll/questions/answers/images/new"
  end

  def create
    @answer.attributes = images_params

    if @answer.save
      redirect_to polymorphic_path([@namespace, @answer, :images]),
               notice: t("flash.actions.create.poll_question_answer_image")
    else
      render "admin/poll/questions/answers/images/new"
    end
  end

  def destroy
    @image = ::Image.find(params[:id])
    @image.destroy!

    respond_to do |format|
      format.js { render "admin/poll/questions/answers/images/destroy", layout: false }
    end
  end

  private

    def images_params
      params.require(:poll_question_answer).permit(allowed_params)
    end

    def allowed_params
      [:answer_id, images_attributes: image_attributes]
    end

    # def load_answer
    #   @answer = ::Poll::Question::Answer.find(params[:answer_id])
    # end
end
