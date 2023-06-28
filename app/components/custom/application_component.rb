require_dependency Rails.root.join("app", "components", "application_component").to_s

class ApplicationComponent < ViewComponent::Base
  def set_comment_flags(comments)
    @comment_flags = helpers.current_user ? helpers.current_user.comment_flags(comments) : {}
    @comment_flags
  end

  private

    def url_to_footer_tab(
      pagination_page: nil,
      filter: nil,
      order: nil,
      filter_projekt_ids: nil,
      projekt_label_ids: nil
    )

      if params[:projekt_phase_id].present? # single projekt footer tab
        projekt = ProjektPhase.find(params[:projekt_phase_id]).projekt
        page = projekt.page

        page_path(page.slug, selected_phase_id: params[:projekt_phase_id],
          page: pagination_page || params[:page],
          filter: filter || params[:filter],
          order: order || params[:order],
          filter_projekt_ids: filter_projekt_ids || params[:filter_projekt_ids],
          projekt_label_ids: projekt_label_ids || params[:projekt_label_ids]
        )
      end
    end
end
