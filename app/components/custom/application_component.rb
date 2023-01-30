require_dependency Rails.root.join("app", "components", "application_component").to_s

class ApplicationComponent < ViewComponent::Base
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
end
