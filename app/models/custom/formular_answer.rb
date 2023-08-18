class FormularAnswer < ApplicationRecord
  belongs_to :formular
  delegate :formular_fields, to: :formular

  attr_accessor :answer_errors

  def initialize(attributes = {})
    super
    @answer_errors = {}
  end
end
