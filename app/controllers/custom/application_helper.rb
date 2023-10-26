require_dependency Rails.root.join("app", "helpers", "application_helper").to_s

module ApplicationHelper
  def url_to_footer_tab(
    remote: false,
    pagination_page: nil,
    filter: nil,
    order: nil,
    projekt_label_ids: nil,
    sentiment_id: nil,
    section: nil,
    extras: {}
  )
    return "" unless params[:projekt_phase_id].present?

    projekt_phase = ProjektPhase.find(params[:projekt_phase_id])
    url_options = {
      page: pagination_page || params[:page],
      filter: filter || params[:filter],
      order: order || params[:order],
      projekt_label_ids: projekt_label_ids || params[:projekt_label_ids],
      sentiment_id: sentiment_id || params[:sentiment_id],
      section: section || params[:section],
      annotation_id: params[:annotation_id]
    }

    url_options.reject! { |k, v| k == :sentiment_id && v == 0 }

    if remote
      projekt_phase_footer_tab_page_path(projekt_phase.projekt.page, projekt_phase.id, **url_options, **extras)
    else
      page_path(projekt_phase.projekt.page.slug, projekt_phase_id: projekt_phase.id, **url_options, **extras)
    end
  end

  def projekt_footer_phase_filter_url(projekt_phase)
    projekt_phase_footer_tab_page_path(projekt_phase.projekt.page, projekt_phase.id)
  end
end
