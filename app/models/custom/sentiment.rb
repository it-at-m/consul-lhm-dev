class Sentiment < ApplicationRecord
  translates :name, touch: true
  include Globalizable

  belongs_to :projekt_phase
  has_many :resource_sentiments, dependent: :destroy

  default_scope { order(:id) }
end
