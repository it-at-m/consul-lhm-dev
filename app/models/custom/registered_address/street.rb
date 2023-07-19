class RegisteredAddress::Street < ApplicationRecord
  has_many :registered_addresses, dependent: :restrict_with_exception,
    class_name: "RegisteredAddress", foreign_key: :registered_address_street_id
  has_many :registered_address_street_projekt_phases, dependent: :destroy,
    class_name: "RegisteredAddressStreetProjektPhase", foreign_key: :registered_address_street_id
  has_many :projekt_phases, through: :registered_address_street_projekt_phases

  validates :name, presence: true
  validates :plz, presence: true
  validates :name, uniqueness: { scope: :plz }

  def self.table_name_prefix
    "registered_address_"
  end

  def name_with_plz
    plz? ? "#{name} (#{plz})" : name
  end
end
