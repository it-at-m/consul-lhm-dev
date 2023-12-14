module AdminActions::Poll::Results
  extend ActiveSupport::Concern

  included do
    before_action :load_poll
  end

  def index
    authorize! :create, @poll

    @partial_results = @poll.partial_results

    render "admin/poll/results/index"
  end

  private

    def load_poll
      @poll = ::Poll.includes(:questions).find(params[:poll_id])
    end
end
