module Labelable
  extend ActiveSupport::Concern

  included do
    has_many :projekt_labelings, as: :labelable, dependent: :destroy
    has_many :projekt_labels, through: :projekt_labelings

    validates :projekt_labels, presence: true, on: :create, if: :labels_available?
  end

  def labels_available?
    return false if projekt_phase&.nil?

    projekt_phase&.projekt_labels&.exists?
  end
end
