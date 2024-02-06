require_dependency Rails.root.join("app", "models", "geozone").to_s

class Geozone < ApplicationRecord
  has_many :projekt_phase_geozones
  has_many :projekt_phases, through: :projekt_phase_geozones
  has_many :limited_projekts, through: :projekt_phases, source: :projekt
  has_and_belongs_to_many :affiliated_projekts, through: :geozones_projekts, class_name: 'Projekt'

  def self.find_with_plz(plz)
    return nil unless plz.present?

    Geozone.where.not(postal_codes: nil).select do |geozone|
      geozone.postal_codes.split(",").any? do |postal_code|
        postal_code.strip == plz.to_s
      end
    end.first
  end

  def safe_to_destroy?
    Geozone.reflect_on_all_associations(:has_many).all? do |association|
      if association.klass.name == 'User' || association.klass.name == 'ProjektPhaseGeozone'
        association.klass.where(geozone: self).empty?
      elsif association.klass.name.in? ['Proposal', 'Debate']
        association.klass.joins(:geozone_restrictions).where('geozones.id = ?', self.id).empty? &&
          association.klass.joins(:geozone_affiliations).where('geozones.id = ?', self.id).empty?
      elsif association.klass.name.in? ['Projekt']
        association.klass.joins(:geozone_affiliations).where('geozones.id = ?', self.id).empty?
      elsif association.klass.name.in? ['ProjektPhase' ]
        association.klass.joins(:geozone_restrictions).where('geozones.id = ?', self.id).empty?
      else
        association.klass.joins(:geozones).where('geozones.id = ?', self.id).empty?
      end
    end
  end
end
