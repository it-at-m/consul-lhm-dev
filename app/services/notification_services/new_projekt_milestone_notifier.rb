module NotificationServices
  class NewProjektMilestoneNotifier < ApplicationService
    def initialize(projekt_milestone_id)
      @projekt_milestone = Milestone.find(projekt_milestone_id)
    end

    def call
      users_to_notify_ids.each do |user_id|
        NotificationServiceMailer.new_projekt_milestone(user_id, @projekt_milestone.id).deliver_later
      end
    end

    private

      def users_to_notify_ids
        [projekt_subscriber_ids].flatten.uniq
      end

      def projekt_subscriber_ids
        return [] unless @projekt_milestone.milestoneable.is_a?(Projekt)

        @projekt_milestone.projekt.milestone_phase.subscribers.ids
      end
  end
end
