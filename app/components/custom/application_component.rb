require_dependency Rails.root.join("app", "components", "application_component").to_s

class ApplicationComponent < ViewComponent::Base
  delegate :url_to_footer_tab, :current_user, to: :helpers

  def set_comment_flags(comments)
    @comment_flags = helpers.current_user ? helpers.current_user.comment_flags(comments) : {}
    @comment_flags
  end

  private

    def url_for_footer_tab_back_button(page_id:,
                                       current_tab_path:,
                                       pagination_page: 1,
                                       filter: "",
                                       order: "",
                                       filter_projekt_ids: nil,
                                       projekt_label_ids: nil)
      projekt = SiteCustomization::Page.find_by(slug: page_id).projekt
      phase_name = params[:current_tab_path].split("_")[0..-3].join("_")
      current_projekt_phase = projekt.send(phase_name)

      "/#{projekt.page.slug}?selected_phase_id=#{current_projekt_phase.id}" \
        "&id=#{page_id}" \
        "&page=#{pagination_page}" \
        "&filter=#{filter}" \
        "&order=#{order}" \
        "&#{filter_projekt_ids.to_query(:filter_projekt_ids)}" \
        "&#{projekt_label_ids&.to_query(:projekt_label_ids)}"
    end

    def current_path_with_query_params_merged_subarrays(new_query_parameters)
      params = request.query_parameters.dup

      new_query_parameters.stringify_keys.each do |key, value|
        selected_values = params[key].present? ? params[key].split(",") : []

        if selected_values.include?(value)
          selected_values.delete(value)
        else
          selected_values.push(value)
        end

        params[key] = selected_values.join(",")
      end

      params = params.delete_if { |key, value| value.blank? }

      url_for(params.merge(only_path: true))
    end

    def path_for_resource_with_params(resource, params)
      case resource
      when Debate
        debates_path(params)
      when Proposal
        proposals_path(params)
      when Poll
        polls_path(params)
      when Budget::Investment
        budget_investments_path(resource, params)
      when Legislation::Proposal
        legislation_process_proposals_path(resource, params)
      when Projekt
        projekts_path(params)
      else
        "#"
      end
    end
end
