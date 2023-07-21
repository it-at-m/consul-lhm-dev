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
        [projekt_phase_subscriber_ids].flatten.uniq
      end

      def projekt_phase_subscriber_ids
        return [] unless @projekt_event.projekt_phase.present?

        @projekt_event.projekt_phase.subscribers.ids
      end
  end
end
