require_dependency Rails.root.join("app", "components", "shared", "order_links_component").to_s

class Shared::OrderLinksComponent < ApplicationComponent
  private

    def link_path(order)
      if params[:current_tab_path].present? && !helpers.request.path.starts_with?("/projekts")
        url_for(action: params[:current_tab_path],
                controller: "/pages",
                page: 1,
                order: order,
                filter_projekt_ids: params[:filter_projekt_ids],
                anchor: anchor,
                filter: params[:filter])
      else
        current_path_with_query_params(order: order, page: 1, anchor: anchor)
      end
    end

    def title_for(order)
      t("#{i18n_namespace}.orders.#{order}_title")
    end

    def footer_tab_back_button_url(order)
      if controller_name == "pages" &&
          params[:current_tab_path].present? &&
          !helpers.request.path.starts_with?("/projekts")

        url_for_footer_tab_back_button(params[:id], params[:current_tab_path], params[:filter], order, params[:filter_projekt_ids])
      else
        "empty"
      end
    end
end
