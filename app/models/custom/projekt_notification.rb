class ProjektNotification < ApplicationRecord
  belongs_to :projekt # TODO: remove column after data migration con1538

  belongs_to :projekt_phase
  validates :projekt_phase, presence: true
end
