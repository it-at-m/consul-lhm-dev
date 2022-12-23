require_dependency Rails.root.join("app", "components", "application_component").to_s

class ApplicationComponent < ViewComponent::Base
  def set_comment_flags(comments)
    @comment_flags = helpers.current_user ? helpers.current_user.comment_flags(comments) : {}
    @comment_flags
  end

  private

    def url_for_footer_tab_back_button(page_id,
                                       pagination_page,
                                       current_tab_path = "",
                                       filter = "",
                                       order = "",
                                       filter_projekt_ids = "")
      projekt = SiteCustomization::Page.find_by(slug: page_id).projekt
      phase_name = params[:current_tab_path].split("_")[0..-3].join("_")
      current_projekt_phase = projekt.send(phase_name)

      "/#{projekt.page.slug}?selected_phase_id=#{current_projekt_phase.id}&filter=#{filter}&order=#{order}&#{filter_projekt_ids.to_query(:filter_projekt_ids)}&page=#{pagination_page}"
    end
end
