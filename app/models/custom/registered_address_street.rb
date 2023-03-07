class RegisteredAddressStreet < ApplicationRecord
  has_many :registered_addresses, dependent: :restrict_with_error

  validates :name, presence: true
  validates :plz, presence: true
  validates :name, uniqueness: { scope: :plz }

  def name_with_plz
    plz? ? "#{name} (#{plz})" : name
  end
end
