class ProjektPhase < ApplicationRecord
  belongs_to :projekt
  has_many :projekt_phase_geozones, dependent: :destroy
  has_many :geozones, through: :projekt_phase_geozones

  def selectable_by?(user)
    geozone_allowed = if geozone_restricted && geozone_ids.any?
                        geozone_ids.include?(user.geozone_id) || Setting["feature.user.skip_verification"].present?
                      elsif geozone_restricted
                        user.level_two_or_three_verified? || Setting["feature.user.skip_verification"].present?
                      else 
                        true
                      end

    user.present? &&
      geozone_allowed &&
         self.active &&
           ((self.start_date <= Date.today if self.start_date) || self.start_date.blank? ) &&
             ((self.end_date >= Date.today if self.end_date) || self.end_date.blank? )


  end

  def expired?
    end_date && end_date < Date.today
  end
end
