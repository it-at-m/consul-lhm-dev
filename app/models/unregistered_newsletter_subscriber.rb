class UnregisteredNewsletterSubscriber < ApplicationRecord
  validates :email, presence: true
  has_secure_token :confirmation_token
  has_secure_token :unsubscribe_token

  scope :confirmed, -> {
    where(confirmed: true)
  }

  def not_confirmed?
    !confirmed?
  end
end
