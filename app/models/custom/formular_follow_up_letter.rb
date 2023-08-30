class FormularFollowUpLetter < ApplicationRecord
  belongs_to :formular
  delegate :projekt_phase, to: :formular
  has_many :email_activities, as: :actionable, inverse_of: :actionable, dependent: :restrict_with_error

  has_many :recipients, dependent: :destroy,
    class_name: "FormularFollowUpLetterRecipient", inverse_of: :formular_follow_up_letter
  has_many :formular_answers, through: :recipients

  def draft?
    sent_at.nil?
  end

  def deliver
    run_at = Time.current

    recipients_in_batches.each do |recipients_batch|
      recipients_batch.each do |recipient|
        if recipient.email.present?
          Mailer.delay(run_at: run_at).formular_follow_up_letter(self, recipient)
          log_delivery(recipient.email)
        end
      end
      run_at += 20.minutes
    end
  end

  def recipients_in_batches
    recipients.in_groups_of(1000, false)
  end

  private

    def log_delivery(email)
      EmailActivity.log(email, self)
    end
end
