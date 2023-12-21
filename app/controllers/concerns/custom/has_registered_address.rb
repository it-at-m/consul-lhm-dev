module HasRegisteredAddress
  extend ActiveSupport::Concern

  private

    def process_temp_attributes_for(resource)
      resource.form_registered_address_city_id = params[:form_registered_address_city_id]
      resource.form_registered_address_street_id = params[:form_registered_address_street_id]
      resource.form_registered_address_id = params[:form_registered_address_id]

      resource.registered_address_id = nil if params[:form_registered_address_city_id] == "0"

      return if resource.regular_address_fields_visible?

      resource.errors.add(:form_registered_address_id, :blank) if params[:form_registered_address_id].blank?
    end

    def set_address_attributes
      if params[:form_registered_address_id].present? && params[:form_registered_address_id] != "0"
        registered_address = RegisteredAddress.find(params[:form_registered_address_id])
        params[:user][:registered_address_id] = registered_address.id

        params[:user][:city_name] = registered_address.registered_address_city.name
        params[:user][:plz] = registered_address.registered_address_street.plz
        params[:user][:street_name] = registered_address.registered_address_street.name
        params[:user][:street_number] = registered_address.street_number
        params[:user][:street_number_extension] = registered_address.street_number_extension
      end
    end

    def set_address_objects_from_temp_attributes_for(resource)
      @registered_address_city = RegisteredAddress::City.find_by(id: params[:form_registered_address_city_id])
      @registered_address_street = RegisteredAddress::Street.find_by(id: params[:form_registered_address_street_id])
      @registered_address = RegisteredAddress.find_by(id: params[:form_registered_address_id])
      @selected_city_id = "0" if @registered_address_city.nil? && resource.form_registered_address_city_id.present?
    end
end
