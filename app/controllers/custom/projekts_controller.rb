class ProjektsController < ApplicationController
  skip_authorization_check

  def show
    projekt = Projekt.find(params[:id])

    redirect_to page_path(projekt.page.slug) if projekt.present?
  rescue
    head 404, content_type: "text/html"
  end
end
