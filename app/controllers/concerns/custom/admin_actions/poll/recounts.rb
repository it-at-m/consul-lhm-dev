module AdminActions::Poll::Recounts
  extend ActiveSupport::Concern

  included do
    before_action :load_poll
  end

  def index
    authorize! :create, @poll

    @stats = Poll::Stats.new(@poll)

    @booth_assignments = @poll.booth_assignments.
                              includes(:booth, :recounts, :voters).
                              order("poll_booths.name").
                              page(params[:page]).per(50)

    render "admin/poll/recounts/index"
  end

  private

    def load_poll
      @poll = ::Poll.find(params[:poll_id])
    end
end
