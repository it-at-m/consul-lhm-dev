class RegisteredAddressStreetProjektPhase < ApplicationRecord
  belongs_to :registered_address_street, class_name: "RegisteredAddress::Street",
                                         foreign_key: "registered_address_street_id"
  belongs_to :projekt_phase
end
