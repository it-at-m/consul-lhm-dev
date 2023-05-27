class ProjektSubscription < ApplicationRecord
  belongs_to :projekt
  belongs_to :user
end
