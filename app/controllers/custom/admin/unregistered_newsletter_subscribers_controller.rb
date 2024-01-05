class Admin::UnregisteredNewsletterSubscribersController < Admin::BaseController
  def index
    @unregistered_newsletter_subscribers = UnregisteredNewsletterSubscriber.all.page(params[:page]).per(25)

    respond_to do |format|
      format.html
      format.csv do
        send_data CsvServices::UnregisteredNewsletterSubscribersExporter.call(
          @unregistered_newsletter_subscribers.except(:limit, :offset)
        ), filename: "unregistered-newsletter-subscribers-#{Time.zone.today}.csv"
      end
    end
  end

  def destroy
    @unregistered_newsletter_subscriber = UnregisteredNewsletterSubscriber.find(params[:id])
    @unregistered_newsletter_subscriber.destroy!

    redirect_to admin_unregistered_newsletter_subscribers_path,
      notice: "Erfolgreich gelöscht"
  end
end
