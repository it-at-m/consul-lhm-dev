# frozen_string_literal: true

class Projekts::ListComponent < ApplicationComponent
  def initialize(
    projekts:, **attributes
  )
    @projekts = projekts
    @attributes = attributes
  end

  def call
    @attributes[:filter_param_name] = 'order'

    render(Shared::ResourcesListComponent.new(
      resources: @projekts,
      resource_type: Projekt,
      title: t("custom.projekts.list.title"),
      css_class: "js-projekts-list",
      filter_title: t("custom.projekts.filter.title"),
      empty_list_text: t("custom.projekts.index.no_projekts_for_current_filter"),
      **@attributes
    ))
  end
  #
  # def filters
  #   return if @filters.blank?
  #
  #   @filters.map do |filter|
  #     {
  #       value: filter,
  #       title: t("custom.projekts.orders.#{filter}")
  #     }
  #   end
  # end

  # def current_filter_option
  #   return if filters.blank?
  #
  #   filters.find { |filter_option| filter_option[:value] == @current_filter }
  # end

  # def html_class(order)
  #   "is-active" if order == current_order
  # end
  # def filter_link_path(order)
  #   current_path_with_query_params(order: order, anchor: @anchor)
  # end

  def tag_name(order)
    if order == current_order
      :h2
    else
      :span
    end
  end

  def title_for(order)
    t("custom.projekts.orders.#{order}_title")
  end

  def link_text(order)
    t("custom.projekts.orders.#{order}")
  end
end
