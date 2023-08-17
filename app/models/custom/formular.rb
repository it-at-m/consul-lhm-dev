class Formular < ApplicationRecord
  belongs_to :projekt_phase
  has_many :formular_fields, dependent: :destroy
  has_many :formular_answers, dependent: :destroy
end
