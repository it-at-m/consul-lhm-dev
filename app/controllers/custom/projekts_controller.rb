class ProjektsController < ApplicationController
  skip_authorization_check

  include ProjektControllerHelper

  def show
    projekt = Projekt.find(params[:id])

    redirect_to page_path(projekt.page.slug) if projekt.present?
  rescue
    head 404, content_type: "text/html"
  end

  def update_selected_parent_projekt
    selected_parent_projekt_id = get_highest_unique_parent_projekt_id(params[:selected_projekts_ids])
    render json: {selected_parent_projekt_id: selected_parent_projekt_id }
  end
end
