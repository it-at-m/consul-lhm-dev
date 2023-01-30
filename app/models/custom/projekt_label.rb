class ProjektLabel < ApplicationRecord
  include Iconable

  translates :name, touch: true
  include Globalizable

  belongs_to :projekt

  default_scope { order(:id) }
end
