class Shared::TextSearchFormComponent < ApplicationComponent
  attr_reader :i18n_namespace

  def initialize(i18n_namespace:, remote_url: nil)
    @i18n_namespace = i18n_namespace
    @remote_url = remote_url
  end

  def remote_attribute
    @remote_url.present?
  end

  def form_url
    @remote_url.presence || ""
  end

  def other_query_params_from_current_path
    request.query_parameters&.except("utf8", "page", "search").presence || {}
  end
end
