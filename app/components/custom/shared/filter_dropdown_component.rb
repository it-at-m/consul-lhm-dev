# frozen_string_literal: true

class Shared::FilterDropdownComponent < ApplicationComponent
  attr_reader :i18n_namespace, :anchor, :remote_url
  delegate :current_path_with_query_params, to: :helpers

  def initialize(
    options:,
    selected_option:,
    anchor: nil,
    i18n_namespace:,
    title:,
    remote_url: nil,
    url_param_name: nil,
    in_projekt_footer_tab: false
  )
    @options = options
    @anchor = anchor
    @selected_option = selected_option
    @i18n_namespace = i18n_namespace
    @title = title
    @remote_url = remote_url
    @url_param_name = url_param_name.presence || 'filter'
    @in_projekt_footer_tab = in_projekt_footer_tab
  end

  private

  def selected_option
    translate_option(@selected_option.presence || @options.first)
  end

  def remote?
    remote_url.present?
  end

  def translate_option(option)
    return if option.blank?

    t(option, scope: i18n_namespace)
  end

  def link_path(option)
    if params[:current_tab_path].present? && !helpers.request.path.starts_with?("/projekts")
      params = {}
      params[@url_param_name] = option
      url_for(action: params[:current_tab_path],
              controller: "/pages",
              page: params[:page] || 1,
              anchor: anchor,
              filter_projekt_ids: params[:filter_projekt_ids],
              projekt_label_ids: params[:projekt_label_ids],
              **params)
    elsif remote_url.present?
      url = "#{remote_url}?#{@url_param_name}=#{option}"

      if anchor.present?
        url = "#{url}#?#{anchor}"
      end

      url
    else
      params = {}
      params[@url_param_name] = option
      current_path_with_query_params(anchor: anchor, **params)
    end
  end

  def title_for(option)
    t("#{option}_title", scope: i18n_namespace)
  end

  def footer_tab_back_button_url(option)
    if controller_name == "pages" &&
        params[:current_tab_path].present? &&
        !helpers.request.path.starts_with?("/projekts")

      url_for_footer_tab_back_button(page_id: params[:id],
                                     pagination_page: params[:page],
                                     current_tab_path: params[:current_tab_path],
                                     filter: params[:filter],
                                     order: option,
                                     filter_projekt_ids: params[:filter_projekt_ids],
                                     projekt_label_ids: params[:projekt_label_ids])
    else
      "empty"
    end
  end

  def link_data_attributes(option)
    data = {}

    if remote?
      data["nonblock-remote"] = "true"
      data["remote"] = "true"
    end
    # data['url'] = link_path(option)

    if @in_projekt_footer_tab
      data["footer-tab-back-url"] = footer_tab_back_button_url(option)
    end

    data
  end
end
