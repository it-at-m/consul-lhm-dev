require_dependency Rails.root.join("app", "models", "legislation", "process").to_s

class Legislation::Process < ApplicationRecord
  clear_validators!
  validates_translation :title, presence: true

  belongs_to :projekt

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
