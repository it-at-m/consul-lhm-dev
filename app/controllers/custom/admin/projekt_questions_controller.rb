class Admin::ProjektQuestionsController < Admin::BaseController
  include Translatable

  before_action :set_projekt_phase
  before_action :set_projekt_question, only: [:edit, :update, :destroy]
  before_action :set_projekt_livestream, only: [:new, :create, :update]

  skip_authorization_check

  load_and_authorize_resource :projekt
  load_and_authorize_resource :question, class: "ProjektQuestion", through: :projekt

  def new
    @projekt_question = ProjektQuestion.new
  end

  def create
    @projekt_question = ProjektQuestion.new(projekt_question_params)
    @projekt_question.author = current_user
    @projekt_question.projekt_phase = @projekt_phase

    if @projekt_livestream.present?
      @projekt_question.projekt_livestream = @projekt_livestream
    end

    if @projekt_question.save
      notice = "Question created"
      redirect_to redirect_path(@projekt_phase), notice: notice
    else
      flash.now[:error] = t("admin.legislation.questions.create.error")
      render :new
    end
  end

  def edit
    @projekt_livestream = @projekt_question.projekt_livestream
  end

  def update
    if @projekt_question.update(projekt_question_params)
      notice = "Question updated"

      if @projekt_livestream.present?
        redirect_to redirect_path(@projekt_phase), notice: notice
      else
        redirect_to redirect_path(@projekt_phase), notice: notice
      end
    else
      flash.now[:error] = t("admin.legislation.questions.update.error")
      render :edit
    end
  end

  def destroy
    @projekt_question.destroy!

    redirect_to redirect_path(@projekt_phase),
      notice: t("admin.legislation.questions.destroy.notice")
  end

  def send_notifications
    NotificationServices::ProjektQuestionsNotifier.call(@projekt.id)
    redirect_to edit_admin_projekt_path(@projekt, anchor: "tab-projekt-questions"),
      notice: t("custom.admin.projekts.projekt_questions.index.notifications_sent_notice")
  end

  private

    def question_path
      legislation_process_question_path(@process, @projekt_question)
    end

    def projekt_question_params
      params.require(:projekt_question).permit(
        translation_params(::ProjektQuestion),
        :projekt_phase_id,
        :comments_enabled, :show_answers_count,
        question_options_attributes: [
          :id, :_destroy, translation_params(::ProjektQuestionOption)
        ]
      )
    end

    def set_projekt_phase
      @projekt_phase = ProjektPhase.find(params[:projekt_phase_id])
    end

    def set_projekt_question
      @projekt_question = ProjektQuestion.find(params[:id])
    end

    def set_projekt_livestream
      @projekt_livestream = ProjektLivestream.find_by(id: params[:projekt_livestream_id])
    end

    def redirect_path(projekt_id)
      if @projekt_livestream.present?
        projekt_livestreams_admin_projekt_phase_path(@projekt_phase)
      else
        projekt_questions_admin_projekt_phase_path(@projekt_phase)
      end

      # if params[:namespace] == "projekt_management"
      #   edit_projekt_management_projekt_path(projekt_id) + tab
      # else
      #   edit_admin_projekt_path(projekt_id) + tab
      # end
    end
end
