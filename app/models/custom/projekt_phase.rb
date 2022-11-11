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
    return false if user.blank? || user.organization? || !current?

    geozone_allowed?(user)
  end

  alias_method :votable_by?, :selectable_by?
  alias_method :comments_allowed?, :selectable_by?

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

  def geozone_restrictions_formatted
    geozone_restrictions.map(&:name).flatten.join(", ")
  end

  def geozone_allowed?(user)
    if Setting["feature.user.skip_verification"].present?
      true

    elsif geozone_restricted == "no_restriction" || geozone_restricted.nil?
      true

    elsif geozone_restricted == "only_citizens"
      user.level_three_verified? &&
        user.current_city_citizen?

    elsif geozone_restricted == "only_geozones"
      user.level_three_verified? &&
        geozone_restrictions.include?(user.geozone)

    end
  end

  def geozone_permission_problem(user)
    return nil if Setting["feature.user.skip_verification"].present?

    case geozone_restricted
    when "no_restriction" || nil
      nil
    when "only_citizens"
      if !user.level_three_verified?
        :not_verified
      elsif user.not_current_city_citizen?
        :only_citizens
      end
    when "only_geozones"
      if !user.level_three_verified?
        :not_verified
      elsif !budget_phase.geozone_restrictions.include?(user.geozone)
        :only_specific_geozones
      end
    end
  end



  private

    def touch_updated_at(geozone)
      touch if persisted?
    end

end
