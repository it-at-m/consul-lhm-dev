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
        [projekt_phase_subscriber_ids].flatten.uniq
      end

      def projekt_phase_subscriber_ids
        if @projekt_milestone.milestoneable.is_a?(ProjektPhase::MilestonePhase)
          @projekt_milestone.milestoneable.subscribers.ids
        else
          []
        end
      end
  end
end
