class Admin::RegisteredAddressStreetsController < Admin::BaseController
  load_and_authorize_resource class: RegisteredAddress::Street

  def index
    @registered_address_streets = RegisteredAddress::Street.order(id: :asc).page(params[:page])
  end
end
