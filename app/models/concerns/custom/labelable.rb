module Labelable
  extend ActiveSupport::Concern

  included do
    has_many :projekt_labelings, as: :labelable, dependent: :destroy
    has_many :projekt_labels, through: :projekt_labelings
  end
end
