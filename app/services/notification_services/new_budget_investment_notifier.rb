module NotificationServices
  class NewBudgetInvestmentNotifier < ApplicationService
    def initialize(investment_id)
      @investment = Budget::Investment.find(investment_id)
    end

    def call
      users_to_notify_ids.each do |user_id|
        NotificationServiceMailer.new_budget_investment(user_id, @investment.id).deliver_later
      end
    end

    private

      def users_to_notify_ids
        [projekt_phase_subscriber_ids].flatten.uniq
          .reject { |id| id == @investment.author.id }
      end

      def projekt_phase_subscriber_ids
        return [] unless @investment.projekt_phase.present?

        @investment.projekt_phase.subscribers.ids
      end
  end
end
