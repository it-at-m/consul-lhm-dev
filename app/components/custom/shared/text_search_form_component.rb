class Shared::TextSearchFormComponent < ApplicationComponent
  attr_reader :search_path, :i18n_namespace

  def initialize(search_path:, i18n_namespace:)
    @i18n_namespace = i18n_namespace
  end

  def other_query_params_from_current_path
    request.query_parameters&.except("utf8", "page", "search").presence || {}
  end
end
