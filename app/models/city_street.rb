class CityStreet < ApplicationRecord
  has_many :users, dependent: :nullify
end
