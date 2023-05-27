class ProjektPhasesController < ApplicationController
  # include CustomHelper
  # include ProposalsHelper
  # include ProjektControllerHelper

  skip_authorization_check

  def selector_hint_html
    projekt_phase = ProjektPhase.find(params[:id])

    default_text = SiteCustomization::ContentBlock
      .custom_block_for("#{projekt_phase.resources_name}_creation_recommendations", I18n.locale)&.body&.html_safe || " "

    if projekt_phase.projekt_selector_hint.present?
      render html: projekt_phase.projekt_selector_hint.html_safe
    else
      render html: default_text
    end
  end

  def toggle_subscription
    @projekt_phase = ProjektPhase.find(params[:id])

    if @projekt_phase.subscribed?(current_user)
      @projekt_phase.unsubscribe(current_user)
    else
      @projekt_phase.subscribe(current_user)
    end
  end
end
