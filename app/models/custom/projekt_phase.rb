class ProjektPhase < ApplicationRecord
  REGULAR_PROJEKT_PHASES = [
    "ProjektPhase::MilestonePhase",
    "ProjektPhase::ProjektNotificationPhase",
    "ProjektPhase::NewsfeedPhase",
    "ProjektPhase::EventPhase",
    "ProjektPhase::ArgumentPhase",
    "ProjektPhase::LivestreamPhase"
  ].freeze

  belongs_to :projekt, optional: true, touch: true
  has_many :projekt_phase_geozones, dependent: :destroy
  has_many :geozone_restrictions, through: :projekt_phase_geozones, source: :geozone, after_add: :touch_updated_at, after_remove: :touch_updated_at

  scope :regular_phases, -> { where.not(type: REGULAR_PROJEKT_PHASES) }
  scope :special_phases, -> { where(type: REGULAR_PROJEKT_PHASES) }

  def selectable_by?(user)
    # user.present? &&
    #   user.level_two_or_three_verified? &&
    #   geozone_allowed?(user) &&
    #   current?
    user.present? &&
      geozone_allowed?(user) &&
      current?
  end

  def expired?
    end_date.present? && end_date < Date.today
  end

  def current?
    phase_activated? &&
      ((start_date <= Date.today if start_date.present?) || start_date.blank? ) &&
      ((end_date >= Date.today if end_date.present?) || end_date.blank? )
  end

  def not_current?
    !current?
  end

  def not_active?
    !active?
  end

  def only_citizens_allowed?
    geozone_restricted == "only_citizens"
  end

  def only_geozones_allowed?
    geozone_restricted == "only_geozones"
  end

  def citizen_not_allowed?(user)
    only_citizens_allowed? && user.not_current_city_citizen?
  end

  def user_geozone_not_allowed?(user)
    only_geozones_allowed? && geozone_not_allowed?(user)
  end

  def geozone_allowed?(user)
    (geozone_restricted == "no_restriction" || geozone_restricted.nil?) ||

    (geozone_restricted == "only_citizens" &&
      user.present? &&
      user.level_three_verified? &&
      user.current_city_citizen?
    ) ||

    (geozone_restricted == "only_geozones" &&
      user.present? &&
      user.level_three_verified? &&
      geozone_restrictions.blank? &&
      user.current_city_citizen?
    ) ||

    (geozone_restricted == "only_geozones" &&
      user.present? &&
      user.level_three_verified? &&
      geozone_restrictions.any? &&
      geozone_restrictions.include?(user.geozone))
  end

  def geozone_not_allowed?(user)
    !geozone_allowed?(user)
  end

  def geozone_restrictions_formated
    geozone_restrictions.map(&:postal_codes).flatten.join(", ")
  end

  private

    def touch_updated_at(geozone)
      touch if persisted?
    end
end
