class NewsletterSubscriptionMailer < ApplicationMailer
  helper :mailer

  def confirm(email, user: nil, unregistered_newsletter_subscriber: nil)
    # subject = t("custom.notification_service_mailers.projekt_questions.subject")
    @user = user
    @unregistered_newsletter_subscriber = unregistered_newsletter_subscriber
    @unregistered_newletter_unsubscribe_token = unregistered_newsletter_subscriber.unsubscribe_token

    subject = "Anmeldung zum Newsletter"
    mail(to: email, subject: subject)
  end
end
