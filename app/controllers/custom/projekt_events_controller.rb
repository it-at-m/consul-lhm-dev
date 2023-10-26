class ProjektEventsController < ApplicationController
  include CustomHelper
  include ProposalsHelper
  include ProjektControllerHelper

  skip_authorization_check
  has_filters %w[all incoming past], only: [:index]

  def index
    @valid_filters = %w[all incoming past]
    @current_filter = @valid_filters.include?(params[:filter]) ? params[:filter] : "all"

    @projekt_events =
      ProjektEvent
        .all
        .includes(projekt_phase: :projekt)
        .page(params[:page])
        .per(10).send("sort_by_#{@current_filter}")

    if Setting.new_design_enabled?
      render :index_new
    else
      render :index
    end
  end
end
