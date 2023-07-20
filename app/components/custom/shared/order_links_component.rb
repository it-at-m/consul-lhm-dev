require_dependency Rails.root.join("app", "components", "shared", "order_links_component").to_s

class Shared::OrderLinksComponent < ApplicationComponent
  private

    def link_path(order)
      if helpers.request.path.starts_with?("/projekts")
        current_path_with_query_params(order: order, page: 1, anchor: anchor)
      elsif helpers.request.path.starts_with?("/communities")
        current_path_with_query_params(order: order)
      elsif params[:projekt_phase_id].present?
        projekt_phase_footer_tab_page_path(params[:id], params[:projekt_phase_id],
                                            page: params[:page] || 1,
                                            order: order,
                                            filter_projekt_ids: params[:filter_projekt_ids],
                                            anchor: anchor,
                                            projekt_label_ids: params[:projekt_label_ids],
                                            filter: params[:filter]
                                          )
      else
        url_for(action: "index", controller: controller_name, order: order)
      end
    end

    def title_for(order)
      t("#{i18n_namespace}.orders.#{order}_title")
    end

    def footer_tab_back_button_url(order)
      if controller_name == "pages" &&
          params[:projekt_phase_id].present? &&
          !helpers.request.path.starts_with?("/projekts")

        url_to_footer_tab(order: order)
      else
        "empty"
      end
    end
end
