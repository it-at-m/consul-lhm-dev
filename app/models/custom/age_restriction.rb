class AgeRestriction < ApplicationRecord
  translates :name, touch: true
  include Globalizable

  has_many :projekt_phases, dependent: :nullify

  default_scope { order(order: :asc) }
end
