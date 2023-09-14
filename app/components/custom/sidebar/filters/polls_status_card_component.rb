class Sidebar::Filters::PollsStatusCardComponent < ApplicationComponent
  attr_reader :filters
  delegate :current_path_with_query_params, to: :helpers

  def initialize
    @filters = %w[all current expired]
  end

  def current_filter
    @current_filter ||= params[:filter] || filters.first
  end
end
