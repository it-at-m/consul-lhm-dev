module AdminActions::Poll::Polls
  extend ActiveSupport::Concern

  include Translatable
  include ImageAttributes
  include ReportAttributes

  included do
    load_and_authorize_resource except: [:new, :create]
    skip_authorization_check only: :new

    before_action :load_search, only: [:search_booths, :search_officers]
    before_action :load_geozones, only: [:new, :create, :edit, :update]
    before_action :set_projekts_for_selector, only: [:new, :edit, :update]
  end

  def index
    @polls = Poll.not_budget.created_by_admin.order(starts_at: :desc)

    if @namespace == :projekt_management
      @projekts = Projekt.with_pm_permission_to("manage", current_user.projekt_manager)
      @polls = @polls.joins(:projekt_phase).where(projekt_phases: { projekt_id: @projekts.pluck(:id) })
    end

    respond_to do |format|
      format.html { render "admin/poll/polls/index" }
      format.csv do
        send_data Poll::CsvExporter.new(@polls.except(:limit, :offset)).to_csv,
          filename: "polls.csv"
      end
    end
  end

  def show
    @poll = Poll.find(params[:id])
    render "admin/poll/polls/show"
  end

  def new
    @poll = Poll.new
    render "admin/poll/polls/new"
  end

  def create
    @poll = Poll.new(poll_params.merge(author: current_user))
    authorize! :create, @poll

    if @poll.save
      notice = t("flash.actions.create.poll")
      if @poll.budget.present?
        redirect_to polymorphic_path([@namespace, @poll, :booth_assignments]), notice: notice
      else
        redirect_to polymorphic_path([@namespace, @poll]), notice: notice
      end
    else
      render "admin/poll/polls/new"
    end
  end

  def edit
    render "admin/poll/polls/edit"
  end

  def update
    if @poll.update(poll_params)
      redirect_to polymorphic_path([@namespace, @poll]), notice: t("flash.actions.update.poll")
    else
      render "admin/poll/polls/edit"
    end
  end

  def add_question
    question = ::Poll::Question.find(params[:question_id])

    if question.present?
      @poll.questions << question
      notice = t("admin.polls.flash.question_added")
    else
      notice = t("admin.polls.flash.error_on_question_added")
    end
    redirect_to polymorphic_path([@namespace, @poll]), notice: notice
  end

  def booth_assignments
    @polls = Poll.current.created_by_admin
  end

  def destroy
    if ::Poll::Voter.where(poll: @poll).any?
      redirect_to polymorphic_path([@namespace, @poll]), alert: t("admin.polls.destroy.unable_notice")
    else
      @poll.destroy!

      redirect_to polymorphic_path([@namespace, :polls]), notice: t("admin.polls.destroy.success_notice")
    end
  end

  def send_notifications
    NotificationServices::NewPollNotifier.call(@poll.id)
    redirect_to polymorphic_path([@namespace, @poll]), notice: t("custom.admin.polls.poll.notifications_sent")
  end

  private

    def load_geozones
      @geozones = Geozone.all.order(:name)
    end

    def poll_params
      attributes = [:name, :starts_at, :ends_at, :geozone_restricted, :budget_id, :projekt_phase_id,
                    :related_sdg_list, :show_open_answer_author_name, :wizard_mode,
                    :show_summary_instead_of_questions, :show_on_home_page, :show_on_index_page,
                    :tag_list, geozone_ids: [], image_attributes: image_attributes]

      params.require(:poll).permit(*attributes, *report_attributes, translation_params(Poll))
    end

    def search_params
      params.permit(:poll_id, :search)
    end

    def load_search
      @search = search_params[:search]
    end

    def resource
      @poll ||= Poll.find(params[:id])
    end
end
