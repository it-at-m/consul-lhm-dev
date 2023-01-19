class CityStreet < ApplicationRecord
  has_many :users, dependent: :nullify

  def name_with_plz
    plz? ? "#{name} (#{plz})" : name
  end
end
