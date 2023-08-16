class Formular < ApplicationRecord
  belongs_to :projekt_phase
  has_many :formular_fields, dependent: :destroy

  accepts_nested_attributes_for :formular_fields, allow_destroy: true
end
