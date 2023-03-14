class RegisteredAddress::Street < ApplicationRecord
  has_many :registered_addresses, dependent: :restrict_with_error, class_name: "RegisteredAddress", foreign_key: "registered_address_street_id"

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
