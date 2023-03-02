class ProjektEventsController < ApplicationController
  include CustomHelper
  include ProposalsHelper
  include ProjektControllerHelper

  skip_authorization_check
  has_filters %w[all incoming past], only: [:index]

  def index
    @valid_filters = %w[all incoming past]
    @current_filter = @valid_filters.include?(params[:filter]) ? params[:filter] : "incoming"

    @projekt_events = ProjektEvent.all.page(params[:page]).per(10).send("sort_by_#{@current_filter}")
  end
end
