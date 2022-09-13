class ProjektEventsController < ApplicationController
  include CustomHelper
  include ProposalsHelper
  include ProjektControllerHelper

  skip_authorization_check
  has_filters %w[all incoming past], only: [:index]

  before_action do
    raise FeatureFlags::FeatureDisabled, :projekt_events_page unless Setting["extended_feature.general.enable_projekt_events_page"]
  end

  def index
    @valid_filters = %w[all incoming past]
    @current_filter = @valid_filters.include?(params[:filter]) ? params[:filter] : "incoming"

    @projekt_events = ProjektEvent.all.page(params[:page]).per(10).send("sort_by_#{@current_filter}")
  end
end
