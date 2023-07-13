class RegisteredAddress::City < ApplicationRecord
  has_many :registered_addresses, dependent: :restrict_with_exception,
    class_name: "RegisteredAddress", foreign_key: "registered_address_city_id"
  has_many :registered_address_streets, -> { distinct }, through: :registered_addresses,
    foreign_key: "registered_address_street_id"

  def self.table_name_prefix
    "registered_address_"
  end
end
