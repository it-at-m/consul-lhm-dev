class ProjektSubscriptionsController < ApplicationController
  def toggle_subscription
    @projekt_subscription = ProjektSubscription.find(params[:id])
    @projekt = @projekt_subscription.projekt
    authorize! :toggle_subscription, @projekt_subscription

    @projekt_subscription.update!(active: projekt_subscription_params[:active])

    @projekt.projekt_phases.each do |phase|
      @projekt_subscription.active? ? phase.subscribe(current_user) : phase.unsubscribe(current_user)
    end
  end

  private

    def projekt_subscription_params
      params.require(:projekt_subscription).permit(:active)
    end
end
