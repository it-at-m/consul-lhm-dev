class ProjektsController < ApplicationController
  skip_authorization_check

  before_action do
    raise FeatureFlags::FeatureDisabled, :projekts_overview unless Setting['projekts.overview_page']
  end

  include ProjektControllerHelper

  def index
    @current_projekts = Projekt.
      current.
      joins( 'INNER JOIN projekt_settings show_in_overview_page ON projekts.id = show_in_overview_page.projekt_id' ).
      where( 'show_in_overview_page.key': 'projekt_feature.general.show_in_overview_page', 'show_in_overview_page.value': 'active' )

    @expired_projekts = Projekt.
      expired.
      joins( 'INNER JOIN projekt_settings show_in_overview_page ON projekts.id = show_in_overview_page.projekt_id' ).
      where( 'show_in_overview_page.key': 'projekt_feature.general.show_in_overview_page', 'show_in_overview_page.value': 'active' )
  end

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
