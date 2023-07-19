module NotificationServices
  class NewProjektEventNotifier < ApplicationService
    def initialize(projekt_event_id)
      @projekt_event = ProjektEvent.find(projekt_event_id)
    end

    def call
      users_to_notify_ids.each do |user_id|
        NotificationServiceMailer.new_projekt_event(user_id, @projekt_event.id).deliver_later
      end
    end

    private

      def users_to_notify_ids
        [projekt_subscriber_ids].flatten.uniq
      end

      def projekt_subscriber_ids
        @projekt_event.projekt.event_phase.subscribers.ids
      end
  end
end
