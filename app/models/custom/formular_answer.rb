class FormularAnswer < ApplicationRecord
  belongs_to :formular
  delegate :formular_fields, to: :formular

  attr_accessor :answer_errors

  def email_address
    email_key = formular.formular_fields
      .where(kind: "email").where("options ->> 'email_for_confirmation' = ?", "1").first.key
    answers[email_key]
  end
end
