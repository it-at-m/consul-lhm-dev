module AdminActions::Poll::OfficerAssignments
  extend ActiveSupport::Concern

  included do
    before_action :load_poll
    before_action :redirect_if_blank_required_params, only: [:by_officer]
    before_action :load_booth_assignment, only: [:create]
  end

  def index
    authorize! :create, @poll

    @officers = ::Poll::Officer.
                  includes(:user).
                  order("users.username").
                  where(
                    id: @poll.officer_assignments.select(:officer_id).distinct.map(&:officer_id)
                  ).page(params[:page]).per(50)

    render "admin/poll/officer_assignments/index"
  end

  def by_officer
    authorize! :create, @poll

    @poll = ::Poll.includes(:booths).find(params[:poll_id])
    @officer = ::Poll::Officer.includes(:user).find(officer_assignment_params[:officer_id])
    @officer_assignments = ::Poll::OfficerAssignment.
                           joins(:booth_assignment).
                           includes(:recounts, booth_assignment: :booth).
                           by_officer_and_poll(@officer.id, @poll.id).
                           order(:date)

    render "admin/poll/officer_assignments/by_officer"
  end

  def search_officers
    authorize! :create, @poll

    load_search

    poll_officers = User.where(id: @poll.officers.pluck(:user_id))
    @officers = poll_officers.search(@search).order(username: :asc)

    respond_to do |format|
      format.js { render "admin/poll/officer_assignments/search_officers" }
    end
  end

  private

    def officer_assignment_params
      params.permit(:officer_id)
    end

    def create_params
      params.permit(:poll_id, :booth_id, :date, :officer_id)
    end

    def load_booth_assignment
      find_params = { poll_id: create_params[:poll_id], booth_id: create_params[:booth_id] }
      @booth_assignment = ::Poll::BoothAssignment.includes(:poll).find_by(find_params)
    end

    def load_poll
      @poll = ::Poll.find(params[:poll_id])
    end

    def redirect_if_blank_required_params
      if officer_assignment_params[:officer_id].blank?
        redirect_to polymorphic_path([@namespace, @poll])
      end
    end

    def search_params
      params.permit(:poll_id, :search)
    end

    def load_search
      @search = search_params[:search]
    end
end
