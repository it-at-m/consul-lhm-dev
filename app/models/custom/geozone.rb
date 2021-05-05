require_dependency Rails.root.join("app", "models", "geozone").to_s

class Geozone < ApplicationRecord
  has_many :projekt_phase_geozones
  has_many :projekt_phases, through: :projekt_phase_geozones
  has_many :projekts, through: :projekt_phases
end
