class RegisteredAddressesController < ApplicationController
  skip_authorization_check

  def find
    @selected_city_id = params[:selected_city_id]

    if params[:selected_city_id].present?
      @registered_address_city = RegisteredAddress::City.find_by(id: params[:selected_city_id])
    end

    if @registered_address_city.present? && params[:selected_street_id].present?
      @registered_address_street = RegisteredAddress::Street.find_by(id: params[:selected_street_id])
    end
  end
end
