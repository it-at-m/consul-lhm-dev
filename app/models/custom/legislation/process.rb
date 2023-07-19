require_dependency Rails.root.join("app", "models", "legislation", "process").to_s

class Legislation::Process < ApplicationRecord
  clear_validators!
  validates_translation :title, presence: true

  belongs_to :old_projekt, class_name: "Projekt", foreign_key: "projekt_id" # TODO: remove column after data migration con1538

  delegate :projekt, to: :projekt_phase
  belongs_to :projekt_phase, touch: true

  has_many :geozone_restrictions, through: :legislation_phase
  has_many :geozone_affiliations, through: :projekt

  delegate :votable_by?, to: :legislation_phase
  delegate :comments_allowed?, to: :legislation_phase

  validates :projekt_phase_id, presence: true, on: :create

  scope :active, -> { all }

  def calculate_tsvector
  end

  def status
  end

  def draft_phase
    Legislation::Process::Phase.new(
      allegations_start_date,
      allegations_end_date,
      allegations_phase_enabled
    )
  end
end
