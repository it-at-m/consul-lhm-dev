class UnregisteredNewsletterSubscribersController < ApplicationController
  skip_authorization_check

  def create
    @email_input = unregistered_newsletter_reciever_params[:email].presence

    if @email_input
      @existing_user = User.find_by(email: @email_input)
      @existing_unregistered_newsletter_subscriber = UnregisteredNewsletterSubscriber.find_by(
        email: @email_input
      )
    end

    if @existing_user.present?
      Mailer.newsletter_subscription_for_existing_user(@existing_user).deliver_later
      @subscriber_email = @existing_user.email

    elsif @existing_unregistered_newsletter_subscriber.present?
      @subscriber_email = @existing_unregistered_newsletter_subscriber.email

      if @existing_unregistered_newsletter_subscriber.not_confirmed?
        NewsletterSubscriptionMailer.confirm(
          @existing_unregistered_newsletter_subscriber.email,
          unregistered_newsletter_subscriber: @existing_unregistered_newsletter_subscriber
        ).deliver_later
      end

    else
      @unregistered_newsletter_subscriber =
        UnregisteredNewsletterSubscriber.new(
          email: @email_input
        )

      if @unregistered_newsletter_subscriber.save
        NewsletterSubscriptionMailer.confirm(
          @unregistered_newsletter_subscriber.email,
          unregistered_newsletter_subscriber: @unregistered_newsletter_subscriber
        ).deliver_later

        @subscriber_email = @unregistered_newsletter_subscriber.email
      else
        respond_to do |format|
          format.js { render "errors.js.erb" }
        end
      end

    end
  end

  def confirm_subscription
    subscriber = UnregisteredNewsletterSubscriber.find_by(confirmation_token: params[:confirmation_token])

    subscriber.update!(confirmed: true)

    redirect_to root_path, notice: t("custom.newsletters.subscription.successfully_subscribed")
  end

  def unsubscribe
    subscriber = UnregisteredNewsletterSubscriber.find_by(unsubscribe_token: params[:unsubscribe_token])

    subscriber.destroy!

    redirect_to root_path, notice: t("custom.newsletters.subscription.successfully_unsubscribed")
  end

  private

    def unregistered_newsletter_reciever_params
      params.require(:unregistered_newsletter_subscriber).permit(
        :email
      )
    end
end
