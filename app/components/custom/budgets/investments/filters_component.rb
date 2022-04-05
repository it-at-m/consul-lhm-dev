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
          onclick: (controller_name == 'pages' ? '$(".spinner-placeholder").addClass("show-loader")' : '')
        ]
      end
    end

    def link_path(filter)
      if params[:current_tab_path] == 'budget_phase_footer_tab'
        url_for(action: params[:current_tab_path], controller: 'pages', page: 1, filter: filter, filter_projekt_ids: params[:filter_projekt_ids], section: params[:section] )
      else
        current_path_with_query_params(filter: filter, page: 1)
      end
    end

    def remote?
      controller_name == 'pages'
    end
end
