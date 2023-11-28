class Admin::RegisteredAddressesController < Admin::BaseController
  def index
    @registered_addresses = RegisteredAddress.order(id: :asc).page(params[:page])

    respond_to do |format|
      format.html
      format.csv do
        send_data CsvServices::RegisteredAddressesExporter.call(@registered_addresses.except(:limit, :offset)), filename: "registered-addresses-#{Time.zone.today}.csv"
      end
    end
  end

  def import
    RegisteredAddress.import(params[:file].path)
    redirect_to admin_registered_addresses_path, notice: "Registered addresses imported."
  end
end
