module NotificationServices
  class NewDebateNotifier < ApplicationService
    def initialize(debate_id)
      @debate = Debate.find(debate_id)
    end

    def call
      users_to_notify_ids.each do |user_id|
        NotificationServiceMailer.new_debate(user_id, @debate.id).deliver_later
      end
    end

    private

      def users_to_notify_ids
        administrator_ids = User.joins(:administrator).where(adm_email_on_new_debate: true).ids
        moderator_ids = User.joins(:moderator).where(adm_email_on_new_debate: true).ids
        projekt_manager_ids = User.joins(projekt_manager: :projekts).where(adm_email_on_new_debate: true)
          .where(projekt_managers: { projekts: { id: @debate.projekt_phase.projekt.id }}).ids

        [administrator_ids, moderator_ids, projekt_manager_ids, projekt_phase_subscriber_ids].flatten.uniq
          .reject { |id| id == @debate.author_id }
      end

      def projekt_phase_subscriber_ids
        return [] unless @debate.projekt_phase.present?

        @debate.projekt_phase.subscribers.ids
      end
  end
end
