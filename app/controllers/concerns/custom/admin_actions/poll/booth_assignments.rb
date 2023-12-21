module AdminActions::Poll::BoothAssignments
  extend ActiveSupport::Concern

  included do
    before_action :load_poll, except: [:create]
  end

  def index
    authorize! :create, @poll

    @booth_assignments = @poll.booth_assignments.includes(:booth).order("poll_booths.name")
                              .page(params[:page]).per(50)

    render "admin/poll/booth_assignments/index"
  end

  def search_booths
    authorize! :create, @poll

    load_search
    @booths = ::Poll::Booth.quick_search(@search)
    respond_to do |format|
      format.js { render "admin/poll/booth_assignments/search_booths" }
    end
  end

  def show
    authorize! :create, @poll

    included_relations = [:recounts, :voters, officer_assignments: [officer: [:user]]]
    @booth_assignment = @poll.booth_assignments.includes(*included_relations).find(params[:id])
    @voters_by_date = @booth_assignment.voters.group_by { |v| v.created_at.to_date }
    @partial_results = @booth_assignment.partial_results
    @recounts = @booth_assignment.recounts

    render "admin/poll/booth_assignments/show"
  end

  def create
    @poll = Poll.find(booth_assignment_params[:poll_id])
    authorize! :create, @poll

    @booth = Poll::Booth.find(booth_assignment_params[:booth_id])
    @booth_assignment = ::Poll::BoothAssignment.new(poll: @poll, booth: @booth)

    @booth_assignment.save!

    respond_to do |format|
      format.js { render "admin/poll/booth_assignments/create", layout: false }
    end
  end

  def destroy
    authorize! :create, @poll

    @booth_assignment = @poll.booth_assignments.find(params[:id])
    @booth = @booth_assignment.booth

    @booth_assignment.destroy!

    respond_to do |format|
      format.js { render "admin/poll/booth_assignments/destroy", layout: false }
    end
  end

  def manage
    authorize! :create, @poll

    @booths = ::Poll::Booth.all.order(name: :asc).page(params[:page]).per(300)
    # @poll = Poll.find(params[:poll_id])

    render "admin/poll/booth_assignments/manage"
  end

  private

    def load_booth_assignment
      @booth_assignment = ::Poll::BoothAssignment.find(params[:id])
    end

    def booth_assignment_params
      params.permit(:booth_id, :poll_id)
    end

    def load_poll
      @poll = ::Poll.find(params[:poll_id])
    end

    def search_params
      params.permit(:poll_id, :search)
    end

    def load_search
      @search = search_params[:search]
    end
end
