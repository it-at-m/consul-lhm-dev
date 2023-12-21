class Users::RegisteredAddressFieldsComponent < ApplicationComponent
  def initialize(user: nil, registered_address_city: nil, registered_address_street: nil, registered_address: nil, selected_city_id: nil)
    @user = user
    @registered_address_city = registered_address_city
    @registered_address_street = registered_address_street
    @registered_address = registered_address
    @selected_city_id = selected_city_id
  end

  def render?
    RegisteredAddress.any?
  end

  private

    def options_for_city_select
      RegisteredAddress::City.all.map { |city| [city.name, city.id] }.push([t("custom.helpers.select.not_in_list"), 0])
    end

    def selected_city
      @registered_address_city&.id || @selected_city_id
    end

    def options_for_street_select
      return [] unless @registered_address_city.present?

      @registered_address_city.registered_address_streets.map { |str| [str.name_with_plz, str.id] }
    end

    def selected_street
      @registered_address_street&.id
    end

    def options_for_address_select
      return [] unless @registered_address_street.present?

      @registered_address_street.registered_addresses.map { |adr| [adr.formatted_name, adr.id] }
    end

    def selected_address
      @registered_address&.id
    end

    def highlight_error?(field_value)
      @user&.errors&.any? && @user.errors.messages[:form_registered_address_id].present? && field_value.blank?
    end
end
