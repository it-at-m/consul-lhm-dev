module NotificationServices
  class NewProposalNotifier < ApplicationService
    def initialize(proposal_id)
      @proposal = Proposal.find(proposal_id)
    end

    def call
      users_to_notify_ids.each do |user_id|
        NotificationServiceMailer.new_proposal(user_id, @proposal.id).deliver_later
      end
    end

    private

      def users_to_notify_ids
        administrator_ids = User.joins(:administrator).where(adm_email_on_new_proposal: true).ids
        moderator_ids = User.joins(:moderator).where(adm_email_on_new_proposal: true).ids
        projekt_manager_ids = User.joins(projekt_manager: :projekts).where(adm_email_on_new_proposal: true)
          .where(projekt_managers: { projekts: { id: @proposal.projekt_phase.projekt.id }}).ids

        [administrator_ids, moderator_ids, projekt_manager_ids, projekt_phase_subscriber_ids].flatten.uniq
          .reject { |id| id == @proposal.author.id }
      end

      def projekt_phase_subscriber_ids
        return [] unless @proposal.projekt_phase.present?

        @proposal.projekt_phase.subscribers.ids
      end
  end
end
