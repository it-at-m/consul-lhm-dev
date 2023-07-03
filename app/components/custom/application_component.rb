require_dependency Rails.root.join("app", "components", "application_component").to_s

class ApplicationComponent < ViewComponent::Base
  def set_comment_flags(comments)
    @comment_flags = helpers.current_user ? helpers.current_user.comment_flags(comments) : {}
    @comment_flags
  end

  private

    def url_to_footer_tab(
      remote: false,
      pagination_page: nil,
      filter: nil,
      order: nil,
      projekt_label_ids: nil,
      sentiment_id: nil
    )
      return "" unless params[:projekt_phase_id].present?

      projekt_phase = ProjektPhase.find(params[:projekt_phase_id])
      url_options = {
        page: pagination_page || params[:page],
        filter: filter || params[:filter],
        order: order || params[:order],
        projekt_label_ids: projekt_label_ids || params[:projekt_label_ids],
        sentiment_id: sentiment_id || params[:sentiment_id]
      }

      url_options.reject! { |k, v| k == :sentiment_id && v == 0 }

      if remote
        projekt_phase_footer_tab_page_path(projekt_phase.projekt.page, projekt_phase.id, **url_options)
      else
        page_path(projekt_phase.projekt.page.slug, selected_phase_id: projekt_phase.id, **url_options)
      end
    end
end
