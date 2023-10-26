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
      if params[:projekt_phase_id].present?
        url_to_footer_tab(filter: filter, remote: true)
      else
        current_path_with_query_params(filter: filter, page: 1)
      end
    end

    def footer_tab_back_button_url(filter)
      if params[:projekt_phase_id].present?
        url_to_footer_tab(filter: filter)
      else
        "empty"
      end
    end

    def remote?
      controller_name.in?(["pages", "lines"])
    end
end
