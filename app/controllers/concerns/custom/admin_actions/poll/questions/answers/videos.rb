module AdminActions::Poll::Questions::Answers::Videos
  extend ActiveSupport::Concern

  included do
    before_action :load_answer, only: [:index, :new, :create]
    # before_action :load_video, only: [:edit, :update, :destroy]
    load_and_authorize_resource :video, class: "::Poll::Question::Answer::Video", except: [:new, :create]
  end

  def index
    render "admin/poll/questions/answers/videos/index"
  end

  def new
    @video = ::Poll::Question::Answer::Video.new(answer_id: @answer.id)
    authorize! :create, @video

    render "admin/poll/questions/answers/videos/new"
  end

  def create
    @video = ::Poll::Question::Answer::Video.new(video_params)
    authorize! :create, @video

    if @video.save
      redirect_to polymorphic_path([@namespace, @answer, :videos]),
               notice: t("flash.actions.create.poll_question_answer_video")
    else
      render "admin/poll/questions/answers/videos/new"
    end
  end

  def edit
    render "admin/poll/questions/answers/videos/edit"
  end

  def update
    if @video.update(video_params)
      redirect_to polymorphic_path([@namespace, @video.answer, :videos]),
               notice: t("flash.actions.save_changes.notice")
    else
      render "admin/poll/questions/answers/videos/edit"
    end
  end

  def destroy
    notice = if @video.destroy
               t("flash.actions.destroy.poll_question_answer_video")
             else
               t("flash.actions.destroy.error")
             end
    redirect_back(fallback_location: (request.referer || root_path), notice: notice)
  end

  private

    def video_params
      params.require(:poll_question_answer_video).permit(allowed_params)
    end

    def allowed_params
      [:title, :url, :answer_id]
    end

    def load_answer
      @answer = ::Poll::Question::Answer.find(params[:answer_id])
    end

    # def load_video
    #   @video = ::Poll::Question::Answer::Video.find(params[:id])
    # end
end
