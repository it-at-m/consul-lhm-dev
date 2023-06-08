class ProjektPhaseSubscription < ApplicationRecord
  belongs_to :projekt_phase
  belongs_to :user
end
