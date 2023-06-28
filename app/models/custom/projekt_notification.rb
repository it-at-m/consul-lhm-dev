class ProjektNotification < ApplicationRecord
  belongs_to :old_projekt, class_name: 'Projekt', foreign_key: 'projekt_id' # TODO: remove column after data migration con1538

  delegate :projekt, to: :projekt_phase
  belongs_to :projekt_phase
  validates :projekt_phase, presence: true
end
