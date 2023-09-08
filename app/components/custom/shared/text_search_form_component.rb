class Shared::TextSearchFormComponent < ApplicationComponent
  attr_reader :i18n_namespace

  def initialize(i18n_namespace:, param_name: "search")
    @i18n_namespace = i18n_namespace
    @param_name = param_name
  end

  def other_query_params_from_current_path
    request.query_parameters&.except("utf8", "page", "search").presence || {}
  end
end
