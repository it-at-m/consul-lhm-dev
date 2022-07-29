class ProjektLivestreamsController < ApplicationController
  skip_authorization_check
  respond_to :js

  layout false

  def show
    @current_projekt_livestream = ProjektLivestream.find(params[:id])
    @other_livestreams = @current_projekt_livestream.projekt.projekt_livestreams.select(:id, :title)
  end
end
