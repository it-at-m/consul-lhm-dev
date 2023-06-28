class ProjektLabel < ApplicationRecord
  include Iconable

  translates :name, touch: true
  include Globalizable

  belongs_to :projekt_phase
  has_many :projekt_labelings, dependent: :destroy

  default_scope { order(:id) }
end
