module NotificationServices
  class NewProjektNotificationNotifier < ApplicationService
    def initialize(projekt_notification_id)
      @projekt_notification = ProjektNotification.find(projekt_notification_id)
    end

    def call
      users_to_notify_ids.each do |user_id|
        NotificationServiceMailer.new_projekt_notification(user_id, @projekt_notification.id).deliver_later
      end
    end

    private

      def users_to_notify_ids
        [projekt_phase_subscriber_ids].flatten.uniq
      end

      def projekt_phase_subscriber_ids
        @projekt_notification.projekt_phase.subscribers.ids
      end
  end
end
