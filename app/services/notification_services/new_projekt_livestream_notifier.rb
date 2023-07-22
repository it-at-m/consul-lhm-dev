module NotificationServices
  class NewProjektLivestreamNotifier < ApplicationService
    def initialize(projekt_livestream_id)
      @projekt_livestream = ProjektLivestream.find(projekt_livestream_id)
    end

    def call
      users_to_notify_ids.each do |user_id|
        NotificationServiceMailer.new_projekt_livestream(user_id, @projekt_livestream.id).deliver_later
      end
    end

    private

      def users_to_notify_ids
        [projekt_phase_subscriber_ids].flatten.uniq
      end

      def projekt_phase_subscriber_ids
        @projekt_livestream.projekt_phase.subscribers.ids
      end
  end
end
