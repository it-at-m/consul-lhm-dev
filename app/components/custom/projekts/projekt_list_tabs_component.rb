class Projekts::ProjektListTabsComponent < ApplicationComponent
  attr_reader :i18n_namespace, :anchor
  delegate :current_path_with_query_params, :valid_orders, to: :helpers

  def initialize(current_active_orders: {}, current_order: nil, anchor: nil, overview_page: false)
    @i18n_namespace = i18n_namespace
    @anchor = anchor
    @current_active_orders = current_active_orders
    @overview_page = overview_page
    @current_order = current_order
  end

  def current_order
    @current_order.presence || helpers.current_order
  end

  private

    def current_active_orders_sorted
      [
        "index_order_all",
        "index_order_underway",
        "index_order_ongoing",
        "index_order_upcoming",
        "index_order_expired",
        "index_order_individual_list",
        "index_order_drafts"
      ] & @current_active_orders
    end

    def html_class(order)
      "is-active" if order == current_order
    end

    def tag_name(order)
      if order == current_order
        :h2
      else
        :span
      end
    end

    def link_path(order)
      current_path_with_query_params(order: order, anchor: anchor)
    end

    def title_for(order)
      t("custom.projekts.orders.#{order}_title")
    end

    def link_text(order)
      t("custom.projekts.orders.#{order}")
    end
end
