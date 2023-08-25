class FormularFollowUpLetterRecipient < ApplicationRecord
  belongs_to :formular_follow_up_letter
  belongs_to :formular_answer

  after_create :copy_email_address

  private

    def copy_email_address
      update(email: formular_answer.email_address)
    end
end
