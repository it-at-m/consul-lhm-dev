class ProjektPhase < ApplicationRecord
  include Mappable
  include Milestoneable
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  after_create :add_default_settings

  REGULAR_PROJEKT_PHASES = [
    "ProjektPhase::LivestreamPhase",
    "ProjektPhase::MilestonePhase",
    "ProjektPhase::ProjektNotificationPhase",
    "ProjektPhase::EventPhase",
    "ProjektPhase::ArgumentPhase",
    "ProjektPhase::NewsfeedPhase"
  ].freeze

  PROJEKT_PHASES_TYPES = [
    "ProjektPhase::CommentPhase",
    "ProjektPhase::DebatePhase",
    "ProjektPhase::ProposalPhase",
    "ProjektPhase::QuestionPhase",
    "ProjektPhase::VotingPhase",
    "ProjektPhase::BudgetPhase",
    "ProjektPhase::LegislationPhase",
    "ProjektPhase::FormularPhase"
  ] + REGULAR_PROJEKT_PHASES

  delegate :icon, :author, :author_id, to: :projekt

  translates :phase_tab_name, touch: true
  translates :cta_button_name, touch: true
  translates :resource_form_title, touch: true
  translates :projekt_selector_hint, touch: true
  translates :labels_name, touch: true
  translates :sentiments_name, touch: true
  include Globalizable

  belongs_to :projekt, touch: true
  has_many :projekt_settings, through: :projekt
  has_many :settings, class_name: "ProjektPhaseSetting", foreign_key: :projekt_phase_id,
    dependent: :destroy, inverse_of: :projekt_phase
  has_many :projekt_labels, dependent: :destroy
  has_many :sentiments, dependent: :destroy

  belongs_to :age_restriction
  has_many :projekt_phase_geozones, dependent: :destroy
  has_many :geozone_affiliations, through: :projekt
  has_many :geozone_restrictions, through: :projekt_phase_geozones, source: :geozone,
           after_add: :touch_updated_at, after_remove: :touch_updated_at

  has_and_belongs_to_many :individual_group_values,
    after_add: :touch_updated_at, after_remove: :touch_updated_at

  has_many :city_street_projekt_phases, dependent: :destroy     # TODO delete
  has_many :city_streets, through: :city_street_projekt_phases  # TODO delete

  has_many :registered_address_street_projekt_phase, dependent: :destroy
  has_many :registered_address_streets, through: :registered_address_street_projekt_phase

  has_many :subscriptions, class_name: "ProjektPhaseSubscription", dependent: :destroy
  has_many :subscribers, through: :subscriptions, source: :user

  has_many :map_layers, as: :mappable, dependent: :destroy
  has_many :comments, as: :commentable, inverse_of: :commentable, dependent: :destroy

  validates :projekt, presence: true

  default_scope { order(:given_order, :id) }

  scope :regular_phases, -> { where.not(type: REGULAR_PROJEKT_PHASES) }
  scope :special_phases, -> { where(type: REGULAR_PROJEKT_PHASES) }

  scope :active, -> { where(active: true) }
  scope :current, ->(timestamp = Time.zone.today) {
    active
      .where("start_date IS NULL OR start_date <= ?", timestamp)
      .where("end_date IS NULL OR end_date >= ?", timestamp)
  }

  scope :sorted, -> do
    regular_phases.sort_by(&:default_order).each do |x|
      x.start_date = Time.zone.today if x.start_date.nil?
    end.sort_by(&:start_date)
  end

  def self.order_phases(ordered_array)
    ordered_array.each_with_index do |phase_id, order|
      find(phase_id).update_column(:given_order, (order + 1))
    end
  end

  def self.model_name
    mname = super
    mname.instance_variable_set(:@route_key, "projekt_phases")
    mname.instance_variable_set(:@singular_route_key, "projekt_phase")
    mname
  end

  def self.any_selectable?(user)
    any? { |phase| phase.selectable_by?(user) }
  end

  def selectable_by?(user)
    permission_problem(user).blank?
  end

  alias_method :votable_by?, :selectable_by?
  alias_method :comments_allowed?, :selectable_by?

  def not_active?
    !active?
  end

  def expired?
    end_date.present? && end_date < Time.zone.today
  end

  def current?
    phase_activated? &&
      ((start_date <= Time.zone.today if start_date.present?) || start_date.blank?) &&
      ((end_date >= Time.zone.today if end_date.present?) || end_date.blank?)
  end

  def not_current?
    !current?
  end

  def permission_problem(user, location: nil)
    return :not_logged_in unless user
    return :phase_not_active if not_active?
    return :phase_expired if expired?
    return :phase_not_current if not_current?
    return :not_verified if verification_restricted && !user.level_three_verified?

    if phase_specific_permission_problems(user, location).present?
      return phase_specific_permission_problems(user, location)
    end

    unless Setting["feature.user.skip_verification"].present?
      return age_permission_problem(user) if age_permission_problem(user).present?
      return geozone_permission_problem(user) if geozone_permission_problem(user)
      return advanced_geozone_restriction_permission_problem(user) if advanced_geozone_restriction_permission_problem(user).present?
      return individual_group_value_permission_problem(user) if individual_group_value_permission_problem(user).present?
    end

    nil
  end

  def geozone_allowed?(user)
    geozone_permission_problem(user).present?
  end

  def geozone_restrictions_formatted
    geozone_restrictions.map(&:name).flatten.join(", ")
  end

  def street_restrictions_formatted
    registered_address_streets.map(&:name).flatten.join(", ")
  end

  def age_restriction_formatted
    age_restriction.present? ? age_restriction.name.downcase : ""
  end

  def individual_group_value_restriction_formatted
    individual_group_values.map(&:name).flatten.join(", ")
  end

  def resource_count
    nil
  end

  def selectable_by_admins_only?
    false
  end

  def subscribed?(user)
    return false unless user

    subscriptions.where(user_id: user.id).exists?
  end

  def subscribe(user)
    return false unless user

    subscriptions.create(user_id: user.id)
  end

  def unsubscribe(user)
    return false unless user

    subscriptions.where(user_id: user.id).destroy_all
  end

  def title
    phase_tab_name.presence || model_name.human
  end

  def all_settings
    @settings ||= settings.pluck(:key, :value)
  end

  def feature?(key)
    setting = settings.find { |s| s.key == "feature.#{key}" }

    if setting.present?
      setting.value.present?
    else
      false
    end
  end

  def option(key)
    option = settings.find { |s| s.key == "option.#{key}" }

    if option.present?
      option.value.present?
    else
      nil
    end
  end

  def create_map_location
    return if map_location.present?

    MapLocation.create!(
      latitude: Setting["map.latitude"],
      longitude: Setting["map.longitude"],
      zoom: Setting["map.zoom"],
      projekt_phase_id: id
    )
  end

  def admin_nav_bar_items
    []
  end

  def safe_to_destroy?
    false
  end

  def projekt_labels_label_text
    labels_name.presence || I18n.t("custom.projekts.page.footer.sidebar.projekt_labels.title")
  end

  def sentiment_label_text
    sentiments_name.presence || I18n.t("custom.projekts.page.footer.sidebar.sentiments.title")
  end

  def map_location_with_admin_shape
    return nil unless map_location.present?

    map_location.show_admin_shape? ? map_location : nil
  end

  def subscribable?
    true
  end

  private

    def phase_specific_permission_problems(user)
      nil
    end

    def geozone_permission_problem(user)
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
        elsif !geozone_restrictions.include?(user.geozone)
          :only_specific_geozones
        end
      when "only_streets"
        if !user.level_three_verified?
          :not_verified
        elsif !registered_address_streets.include?(user.registered_address_street)
          :only_specific_streets
        end
      end
    end

    def advanced_geozone_restriction_permission_problem(user)
      return nil if registered_address_grouping_restriction.blank? || registered_address_grouping_restriction == "no_restriction"

      if user.registered_address.blank?
        :no_registered_address
      elsif !user.level_three_verified?
        :not_verified
      elsif !user_registered_address_permitted?(user)
        :only_specific_registered_address_groupings
      end
    end

    def user_registered_address_permitted?(user)
      registered_address_grouping_restrictions[registered_address_grouping_restriction]&.include?(user.registered_address.groupings[registered_address_grouping_restriction])
    end

    def age_permission_problem(user)
      return nil if user.age.blank?
      return nil if age_restriction.blank?
      return :not_verified if !user.level_three_verified?
      return nil if (age_restriction.min_age || 0) <= user.age && user.age <= (age_restriction.max_age || 200)

      :only_specific_ages
    end

    def individual_group_value_permission_problem(user)
      return nil if individual_group_values.blank?
      return nil if (individual_group_values & user.individual_group_values).any?

      :only_specific_individual_group_values
    end

    def touch_updated_at(geozone)
      touch if persisted?
    end

    def add_default_settings
      phase_settings = ProjektPhaseSetting.defaults[self.class.name] || {}

      phase_settings.each do |key, value|
        settings.create!(key: key, value: value)
      end
    end
end
