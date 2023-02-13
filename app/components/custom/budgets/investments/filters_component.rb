require_dependency Rails.root.join("app", "components", "budgets", "investments", "filters_component").to_s

class Budgets::Investments::FiltersComponent < ApplicationComponent
  private

    def filters
      valid_filters.map do |filter|
        [
          t("budgets.investments.index.filters.#{filter}"),
          link_path(filter),
          current_filter == filter,
          remote: remote?,
          class: "js-remote-link-push-state",
          "data-footer-tab-back-url": footer_tab_back_button_url(filter),
          onclick: (controller_name == "pages" ? '$(".spinner-placeholder").addClass("show-loader")' : "")
        ]
      end
    end

    def link_path(filter)
      if params[:current_tab_path].present? && !helpers.request.path.starts_with?("/projekts")
        url_for(action: params[:current_tab_path],
                controller: "/pages",
                page: 1,
                filter: filter,
                filter_projekt_ids: params[:filter_projekt_ids],
                section: params[:section],
                id: params[:id],
                order: params[:order])
      else
        current_path_with_query_params(filter: filter, page: 1)
      end
    end

    def footer_tab_back_button_url(filter)
      if controller_name == "pages" &&
          params[:current_tab_path].present? &&
          !helpers.request.path.starts_with?("/projekts")

        url_for_footer_tab_back_button(page_id: params[:id],
                                       pagination_page: params[:page],
                                       current_tab_path: params[:current_tab_path],
                                       filter: filter,
                                       order: params[:order],
                                       filter_projekt_ids: params[:filter_projekt_ids])
      else
        "empty"
      end
    end

    def remote?
      controller_name == "pages"
    end
end
