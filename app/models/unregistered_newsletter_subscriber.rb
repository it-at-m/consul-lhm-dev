class UnregisteredNewsletterSubscriber < ApplicationRecord
  validates :email, presence: true
  has_secure_token :confirmation_token
  has_secure_token :unsubscribe_token

  scope :confirmed, -> {
    where(confirmed: true)
  }

  after_create :send_subscription_confirmation_email

  def not_confirmed?
    !confirmed?
  end

  def send_subscription_confirmation_email
    NewsletterSubscriptionMailer.confirm(self.email, unregistered_newsletter_subscriber: self).deliver_now
  end
end
