class Admin::RegisteredAddressStreetsController < Admin::BaseController
  load_and_authorize_resource :registered_address_street

  def index
    @registered_address_streets = RegisteredAddressStreet.order(id: :asc).page(params[:page])
  end
end
