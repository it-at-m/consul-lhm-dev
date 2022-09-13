require_dependency Rails.root.join("app", "components", "shared", "order_links_component").to_s

class Shared::OrderLinksComponent < ApplicationComponent
  private
    def link_path(order)
      if params[:current_tab_path].present? && !helpers.request.path.starts_with?('/projekts')
        url_for(action: params[:current_tab_path], controller: 'pages', order: order, page: 1, anchor: anchor, filter_projekt_ids: params[:filter_projekt_ids])
      else
        current_path_with_query_params(order: order, page: 1, anchor: anchor)
      end
    end

    def title_for(order)
      t("#{i18n_namespace}.orders.#{order}_title")
    end
end
