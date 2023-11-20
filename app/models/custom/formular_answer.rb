class FormularAnswer < ApplicationRecord
  has_many :formular_follow_up_letter_recipients

  has_many :formular_answer_images, dependent: :destroy
  accepts_nested_attributes_for :formular_answer_images, allow_destroy: true, update_only: true

  belongs_to :formular
  belongs_to :submitter, class_name: "User", foreign_key: "submitter_id", optional: true
  delegate :formular_fields, to: :formular

  attr_accessor :answer_errors

  def email_address
    email_key = formular.formular_fields
      .where(kind: "email").where("options ->> 'email_for_confirmation' = ?", "1").first&.key
    answers[email_key]
  end
end
