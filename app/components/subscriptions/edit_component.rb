class Subscriptions::EditComponent < ApplicationComponent
  attr_reader :user

  def initialize(user)
    @user = user
  end

  private

    def projekts_with_subscriptions
      projekt_ids_with_subscription = user.projekt_subscriptions.pluck(:projekt_id)
      projekt_ids_with_phase_subscription = user.projekt_phase_subscriptions.joins(projekt_phase: :projekt).pluck("projekts.id")

      relevant_projekt_ids = [projekt_ids_with_subscription + projekt_ids_with_phase_subscription].flatten.uniq
      Projekt.where(id: relevant_projekt_ids).order(:id)
    end
end
