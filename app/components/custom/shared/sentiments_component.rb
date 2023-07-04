class Shared::SentimentsComponent < ApplicationComponent
  delegate :toggle_element_in_array, :pick_text_color, to: :helpers

  def initialize(projekt_phase_id: nil, resource: nil)
    if projekt_phase_id
      @projekt_phase = ProjektPhase.find(projekt_phase_id)
      @sentiments = @projekt_phase.sentiments
    elsif resource
      @projekt_phase = resource.projekt_phase
      @sentiments = [resource.sentiment].compact
    end
  end

  def sentiment_selected?(sentiment)
    params[:sentiment_id] == sentiment.id.to_s
  end

  def link_path(sentiment)
    sentiment_id_for_params = sentiment_selected?(sentiment) ? 0 : sentiment.id
    url_to_footer_tab(remote: true, sentiment_id: sentiment_id_for_params)
  end

  def footer_tab_back_button_url(sentiment)
    sentiment_id_for_params = sentiment_selected?(sentiment) ? 0 : sentiment.id

    if controller_name == "pages" &&
        !helpers.request.path.starts_with?("/projekts")

      url_to_footer_tab(sentiment_id: sentiment_id_for_params)
    else
      "empty"
    end
  end
end
