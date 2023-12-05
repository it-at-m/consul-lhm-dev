class UnregisteredNewsletterSubscribersController < ApplicationController
  skip_authorization_check

  def create
    @existing_user = User.find_by(email: unregistered_newsletter_reciever_params[:email])
    @subscriber_email = @existing_user&.email

    if @existing_user.blank?
      @unregistered_newsletter_subscriber =
        UnregisteredNewsletterSubscriber.find_or_create_by!(
          email: unregistered_newsletter_reciever_params[:email]
        )
      @subscriber_email = @unregistered_newsletter_subscriber.email
    end
  end

  def confirm_subscription
    subscriber = UnregisteredNewsletterSubscriber.find_by(confirmation_token: params[:confirmation_token])

    subscriber.update!(confirmed: true, confirmation_token: nil)

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
