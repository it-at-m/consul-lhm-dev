class AgeRestriction < ApplicationRecord
  translates :name, touch: true
  include Globalizable

  has_many :projekt_phases, dependent: :nullify
end
