class Admin::RegisteredAddressesController < Admin::BaseController
  def index
    @registered_addresses = RegisteredAddress.order(id: :asc).page(params[:page])
  end

  def import
    RegisteredAddress.import(params[:file].path)
    redirect_to admin_registered_addresses_path, notice: "Registered addresses imported."
  end
end
