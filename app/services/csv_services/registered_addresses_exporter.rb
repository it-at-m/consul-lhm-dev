module CsvServices
  class RegisteredAddressesExporter < ApplicationService
    require "csv"

    def initialize(registered_addresses)
      @registered_addresses = registered_addresses
    end

    def call
      CSV.generate(headers: true) do |csv|
        csv << headers

        @registered_addresses.each do |ra|
          csv << row(ra)
        end
      end
    end

    private

      def headers
        %w[id city street_name street_number street_number_extension plz]
      end

      def row(ra)
        ra_row = [
          ra.id,
          ra.registered_address_city.name,
          ra.registered_address_street.name,
          ra.street_number,
          ra.street_number_extension,
          ra.registered_address_street.plz
        ]

        ra_row
      end
  end
end
