# frozen_string_literal: true

class Projekts::ListComponent < ApplicationComponent
  def initialize(
    projekts:, show_more_link: false,
    **attributes
  )
    @projekts = projekts
    @attributes = attributes
    @show_more_link = show_more_link
  end

  def call
    @attributes[:filter_param] = 'order'

    render Shared::ResourcesListComponent.new(
      resources: @projekts,
      resource_type: Projekt,
      title: t("custom.projekts.list.title"),
      css_class: "js-projekts-list",
      filter_title: t("custom.projekts.filter.title"),
      empty_list_text: t("custom.projekts.index.no_projekts_for_current_filter"),
      **@attributes
    ) do |c|
      if @show_more_link
        c.bottom_content do
          link_to("Alle Projekte anzeigen", projekts_path(order: 'index_order_all'), class: "resources-list--more-link")
        end
      end
    end
  end

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
