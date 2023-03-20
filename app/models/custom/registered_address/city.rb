class RegisteredAddress::City < ApplicationRecord
  has_many :registered_addresses, class_name: "RegisteredAddress", foreign_key: "registered_address_city_id"
  has_many :registered_address_streets, -> { distinct }, through: :registered_addresses, foreign_key: "registered_address_street_id"

  def self.table_name_prefix
    "registered_address_"
  end
end
