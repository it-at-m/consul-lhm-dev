module HasRegisteredAddress
  extend ActiveSupport::Concern

  def update_registered_address_street_field
    @registered_address_city = RegisteredAddress::City
      .find_by(id: params[:form_registered_address_city_id])

    if @registered_address_city.present?
      @registered_address_streets = @registered_address_city.registered_address_streets.order(name: :asc)
    else
      @registered_address_streets = []
    end
  end

  def update_registered_address_field
    @registered_address_street = RegisteredAddress::Street
      .find_by(id: params[:form_registered_address_street_id])

    if @registered_address_street.present?
      @registered_addresses = @registered_address_street.registered_addresses
    else
      @registered_addresses = []
    end
  end

  private

    def set_registered_address_instance_variables
      @registered_address_city = RegisteredAddress::City.find_by(id: params[:form_registered_address_city_id])
      @registered_address_street = RegisteredAddress::Street.find_by(id: params[:form_registered_address_street_id])
      @registered_address = RegisteredAddress.find_by(id: params[:form_registered_address_id])
    end

    def increase_error_count_for_registered_address_selectors
      return unless resource.extended_registration?

      if RegisteredAddress::City.any?
        if params[:form_registered_address_city_id].blank?
          resource.errors.add(:form_registered_address_city_id, :blank)
        elsif params[:form_registered_address_street_id].blank?
          resource.errors.add(:form_registered_address_street_id, :blank)
        elsif params[:form_registered_address_id].blank?
          resource.errors.add(:form_registered_address_id, :blank)
        end
      end
    end
end
