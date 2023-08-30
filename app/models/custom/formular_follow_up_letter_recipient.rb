class FormularFollowUpLetterRecipient < ApplicationRecord
  belongs_to :formular_follow_up_letter
  belongs_to :formular_answer

  delegate :formular, to: :formular_follow_up_letter

  after_create :copy_email_address, :set_token

  private

    def copy_email_address
      update(email: formular_answer.email_address)
    end

    def set_token
      update(subscription_token: SecureRandom.base58(32))
    end
end
