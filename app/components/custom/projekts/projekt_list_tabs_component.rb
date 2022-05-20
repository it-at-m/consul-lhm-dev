class Projekts::ProjektListTabsComponent < ApplicationComponent
  attr_reader :i18n_namespace, :anchor
  delegate :current_path_with_query_params, :current_order, :valid_orders, to: :helpers

  def initialize(current_active_orders: {}, anchor: nil)
    @i18n_namespace = i18n_namespace
    @anchor = anchor
    @current_active_orders = current_active_orders
  end

  private

  def current_active_orders_sorted
    ['all', 'active', 'ongoing', 'upcoming', 'expired'] & @current_active_orders
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
      if params[:current_tab_path].present?
        url_for(action: params[:current_tab_path], controller: 'pages', order: order, page: 1, anchor: anchor, filter_projekt_ids: params[:filter_projekt_ids])
      else
        current_path_with_query_params(order: order, anchor: anchor)
      end
    end

    def title_for(order)
      t("custom.projekts.orders.#{order}_title")
    end

    def link_text(order)
      t("custom.projekts.orders.#{order}")
    end
end
