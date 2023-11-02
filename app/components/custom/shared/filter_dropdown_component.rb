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
    @url_param_name = url_param_name.presence || "filter"
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

    t("#{i18n_namespace}.#{option}")
  end

  def link_path(option)
    if helpers.params[:projekt_phase_id].present?
      link_options = {}
      link_options[@url_param_name.to_sym] = option
      link_options[:remote] = true
      url_to_footer_tab(link_options)

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

  def footer_tab_back_button_url(option)
    if params[:projekt_phase_id].present?
      url_to_footer_tab([[@url_param_name, option]].to_h.symbolize_keys)
    end
  end

  def link_data_attributes(option)
    data = {}

    if remote?
      data["nonblock-remote"] = "true"
      data["remote"] = "true"
    end

    if @in_projekt_footer_tab
      data["footer-tab-back-url"] = footer_tab_back_button_url(option)
    end

    data
  end

  def link_class
    return unless remote?

    "js-remote-link-push-state" if @in_projekt_footer_tab
  end

  def onclick
    return unless remote?

    if @in_projekt_footer_tab
      "$('#footer-content').addClass('show-loader');"
    else
      "$('.main-column').addClass('show-loader');"
    end
  end
end
