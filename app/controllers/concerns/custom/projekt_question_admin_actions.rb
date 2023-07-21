module ProjektQuestionAdminActions
  extend ActiveSupport::Concern
  include Translatable

  included do
    before_action :set_projekt_phase, :set_namespace
    before_action :set_projekt_question, only: [:edit, :update, :destroy]
    before_action :set_projekt_livestream, only: [:new, :create, :update]
  end

  def new
    @projekt_question = @projekt_phase.questions.new
    authorize!(:new, @projekt_question) unless current_user.administrator?

    render "custom/admin/projekt_questions/edit"
  end

  def create
    @projekt_question = ProjektQuestion.new(projekt_question_params)
    @projekt_question.author = current_user
    @projekt_question.projekt_phase = @projekt_phase

    authorize!(:create, @projekt_question) unless current_user.administrator?

    if @projekt_livestream.present?
      @projekt_question.projekt_livestream = @projekt_livestream
    end

    if @projekt_question.save
      redirect_to redirect_path(@projekt_phase), notice: "Frage erstellt"
    else
      flash.now[:error] = t("admin.legislation.questions.create.error")
      render :new
    end
  end

  def edit
    authorize!(:edit, @projekt_question) unless current_user.administrator?
    @projekt_livestream = @projekt_question.projekt_livestream

    render "custom/admin/projekt_questions/edit"
  end

  def update
    authorize!(:update, @projekt_question) unless current_user.administrator?

    if @projekt_question.update(projekt_question_params)
      redirect_to redirect_path(@projekt_phase), notice: "Frage aktualisiert"
    else
      flash.now[:error] = t("admin.legislation.questions.update.error")
      render :edit
    end
  end

  def destroy
    authorize!(:destroy, @projekt_question) unless current_user.administrator?

    @projekt_question.destroy!

    redirect_to redirect_path(@projekt_phase),
      notice: t("admin.legislation.questions.destroy.notice")
  end

  def send_notifications
    authorize!(:send_notifications, @projekt_phase) unless current_user.administrator?

    NotificationServices::ProjektQuestionsNotifier.call(@projekt_phase.id)
    redirect_to polymorphic_path([@namespace, @projekt_phase], action: :projekt_questions),
      notice: t("custom.admin.projekts.projekt_questions.index.notifications.sent_notice")
  end

  private

    def question_path
      raise NotImplementedError
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

    def set_namespace
      @namespace = params[:controller].split("/").first.to_sym
    end

    def redirect_path(projekt_id)
      if @projekt_livestream.present?
        polymorphic_path([@namespace, @projekt_phase, ProjektLivestream.new])
      else
        polymorphic_path([@namespace, @projekt_phase, ProjektQuestion.new])
      end
    end
end
