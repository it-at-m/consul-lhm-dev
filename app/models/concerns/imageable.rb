module Imageable
  extend ActiveSupport::Concern

  included do
    has_one :image, as: :imageable, inverse_of: :imageable, dependent: :destroy, class_name: "::Image"
    accepts_nested_attributes_for :image, allow_destroy: true, update_only: true
  end
end
