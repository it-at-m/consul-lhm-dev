class Shared::TextSearchFormComponent < ApplicationComponent
  attr_reader :i18n_namespace

  def initialize(i18n_namespace:, remote_url: nil, param_name: "search")
    @i18n_namespace = i18n_namespace
    @remote_url = remote_url
    @param_name = param_name
  end

  def remote_attribute
    @remote_url.present? ? "true" : ""
  end

  def form_url
    @remote_url.present? ? @remote_url : ""
  end

  def other_query_params_from_current_path
    request.query_parameters&.except("utf8", "page", "search").presence || {}
  end
end
