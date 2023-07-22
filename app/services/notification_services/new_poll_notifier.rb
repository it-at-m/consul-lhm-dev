module NotificationServices
  class NewPollNotifier < ApplicationService
    def initialize(poll_id)
      @poll = Poll.find(poll_id)
    end

    def call
      users_to_notify_ids.each do |user_id|
        NotificationServiceMailer.new_poll(user_id, @poll.id).deliver_later
      end
    end

    private

      def users_to_notify_ids
        [projekt_phase_subscriber_ids].flatten.uniq
      end

      def projekt_phase_subscriber_ids
        return [] unless @poll.projekt_phase.present?

        @poll.projekt_phase.subscribers.ids
      end
  end
end
