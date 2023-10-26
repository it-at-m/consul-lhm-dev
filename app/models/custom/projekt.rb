class Projekt < ApplicationRecord
  OVERVIEW_PAGE_NAME = "projekt_overview_page".freeze
  INDEX_FILTERS = %w[
    index_order_underway index_order_all
    index_order_ongoing index_order_upcoming
    index_order_expired index_order_individual_list
  ].freeze

  include Milestoneable
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases
  include Mappable
  include ActiveModel::Dirty
  include SDG::Relatable
  include Taggable

  translates :description
  include Globalizable

  has_many :children, -> { order(order_number: :asc) }, class_name: "Projekt", foreign_key: "parent_id",
    inverse_of: :parent, dependent: :nullify

  has_many :children_projekts_show_in_navigation, -> { show_in_navigation }, class_name: "Projekt", foreign_key: "parent_id"

  has_many :third_level_children, -> { order(order_number: :asc) }, class_name: "Projekt", foreign_key: "top_level_projekt_id",
    inverse_of: :top_level_projekt, dependent: :nullify
  belongs_to :parent, class_name: "Projekt", optional: true
  belongs_to :top_level_projekt, class_name: "Projekt", optional: true

  has_one :page, class_name: "SiteCustomization::Page", dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  has_many :projekt_settings, dependent: :destroy

  has_many :projekt_phases, dependent: :destroy
  has_many :debate_phases, class_name: "ProjektPhase::DebatePhase", dependent: :destroy
  has_many :proposal_phases, class_name: "ProjektPhase::ProposalPhase", dependent: :destroy
  has_many :budget_phases, class_name: "ProjektPhase::BudgetPhase", dependent: :destroy
  has_many :comment_phases, class_name: "ProjektPhase::CommentPhase", dependent: :destroy
  has_many :voting_phases, class_name: "ProjektPhase::VotingPhase", dependent: :destroy
  has_many :milestone_phases, class_name: "ProjektPhase::MilestonePhase", dependent: :destroy
  has_many :projekt_notification_phases, class_name: "ProjektPhase::ProjektNotificationPhase",
    dependent: :destroy
  has_many :newsfeed_phases, class_name: "ProjektPhase::NewsfeedPhase", dependent: :destroy
  has_many :event_phases, class_name: "ProjektPhase::EventPhase", dependent: :destroy
  has_many :legislation_phases, class_name: "ProjektPhase::LegislationPhase", dependent: :destroy
  has_many :question_phases, class_name: "ProjektPhase::QuestionPhase", dependent: :destroy
  has_many :argument_phases, class_name: "ProjektPhase::ArgumentPhase", dependent: :destroy
  has_many :livestream_phases, class_name: "ProjektPhase::LivestreamPhase", dependent: :destroy

  has_and_belongs_to_many :geozone_affiliations, class_name: "Geozone",
    after_add: :touch_updated_at, after_remove: :touch_updated_at
  has_and_belongs_to_many :individual_group_values,
    after_add: :touch_updated_at, after_remove: :touch_updated_at
  has_and_belongs_to_many :hard_individual_group_values, -> { hard }, class_name: "IndividualGroupValue"

  has_many :debates, through: :debate_phases
  has_many :proposals, through: :proposal_phases
  has_many :base_selection_proposals, through: :proposal_phases
  has_many :budgets, through: :budget_phases
  has_many :polls, through: :voting_phases
  has_many :projekt_arguments, through: :argument_phases
  has_many :projekt_livestreams, through: :livestream_phases
  has_many :projekt_notifications, through: :projekt_notification_phases
  has_many :projekt_events, through: :event_phases
  has_many :legislation_processes, through: :legislation_phases

  belongs_to :author, -> { with_hidden }, class_name: "User", inverse_of: :projekts

  has_many :map_layers, as: :mappable, dependent: :destroy

  # has_many :projekt_labels, dependent: :destroy #remove

  has_many :projekt_manager_assignments, dependent: :destroy
  has_many :projekt_managers, through: :projekt_manager_assignments
  accepts_nested_attributes_for :projekt_manager_assignments

  has_many :subscriptions, -> { where(projekt_subscriptions: { active: true }) },
    class_name: "ProjektSubscription", dependent: :destroy, inverse_of: :projekt
  has_many :subscribers, through: :subscriptions, source: :user

  delegate :image, to: :page, allow_nil: true

  # before_validation :set_default_color - should projekt still have a color?
  after_create :create_corresponding_page, :set_order, :create_default_settings,
    :create_map_location
  around_update :update_page
  after_save do
    Projekt.all.find_each { |projekt| projekt.update_column("level", projekt.calculate_level) }
  end

  before_save :assign_top_level_projekt_from_parent
  after_destroy :ensure_projekt_order_integrity

  # validates :color, format: { with: /\A#[\da-f]{6}\z/i } - still color?
  validates :name, presence: true

  scope :regular, -> { where(special: false) }

  scope :with_order_number, -> { where.not(order_number: nil).order(order_number: :asc) }

  scope :top_level, -> {
    with_order_number
      .where(parent: nil)
  }

  scope :activated, -> {
    joins("INNER JOIN projekt_settings act ON projekts.id = act.projekt_id")
      .where("act.key": "projekt_feature.main.activate", "act.value": "active")
  }

  scope :not_activated, -> {
    joins("INNER JOIN projekt_settings nact ON projekts.id = nact.projekt_id")
      .where("nact.key": "projekt_feature.main.activate", "nact.value": [nil, ""])
  }

  scope :current, ->(timestamp = Time.zone.today) {
    activated
      .where("total_duration_start IS NULL OR total_duration_start <= ?", timestamp)
      .where("total_duration_end IS NULL OR total_duration_end >= ?", timestamp)
  }

  scope :expired, ->(timestamp = Time.zone.today) {
    activated
      .where("total_duration_end < ?", timestamp)
  }

  scope :index_order_all, ->() {
    activated
      .with_published_custom_page
      .show_in_overview_page
  }

  scope :index_order_underway, ->() {
    current
      .with_published_custom_page
      .show_in_overview_page
      .not_in_individual_list
      .includes(:projekt_phases)
      .select { |p| p.projekt_phases.regular_phases.any?(&:current?) }
  }

  scope :index_order_ongoing, ->() {
    current
      .with_published_custom_page
      .show_in_overview_page
      .not_in_individual_list
      .includes(:projekt_phases)
      .select { |p| p.projekt_phases.regular_phases.all? { |phase| !phase.current? } }
  }

  scope :index_order_upcoming, ->(timestamp = Time.zone.today) {
    activated
      .with_published_custom_page
      .show_in_overview_page
      .not_in_individual_list
      .where("total_duration_start > ?", timestamp)
  }

  scope :index_order_expired, ->(timestamp = Time.zone.today) {
    expired
      .with_published_custom_page
      .show_in_overview_page
      .not_in_individual_list
  }

  scope :index_order_individual_list, -> {
    with_published_custom_page
      .show_in_overview_page
      .joins("INNER JOIN projekt_settings siil ON projekts.id = siil.projekt_id")
      .where("siil.key": "projekt_feature.general.show_in_individual_list", "siil.value": "active")
  }

  scope :index_order_drafts, -> {
    not_activated
  }

  scope :not_in_individual_list, -> {
    joins("INNER JOIN projekt_settings siil ON projekts.id = siil.projekt_id")
      .where("siil.key": "projekt_feature.general.show_in_individual_list", "siil.value": [nil, ""])
  }

  scope :show_in_overview_page, -> {
    joins("INNER JOIN projekt_settings siop ON projekts.id = siop.projekt_id")
      .where("siop.key": "projekt_feature.general.show_in_overview_page", "siop.value": "active")
  }

  scope :show_in_homepage, -> {
    joins("INNER JOIN projekt_settings sihp ON projekts.id = sihp.projekt_id")
      .where("sihp.key": "projekt_feature.general.show_in_homepage", "sihp.value": "active")
      .order(created_at: :desc)
  }

  scope :show_in_navigation, -> {
    joins("INNER JOIN projekt_settings vim ON projekts.id = vim.projekt_id")
      .where("vim.key": "projekt_feature.general.show_in_navigation", "vim.value": "active")
      .with_order_number
  }

  scope :visible_in_menu, ->(user) {
    select { |p| p.visible_for?(user) }
  }

  scope :show_in_sidebar_filter, ->(user = nil) {
    joins("INNER JOIN projekt_settings show_in_sidebar_filter_settings ON projekts.id = show_in_sidebar_filter_settings.projekt_id")
      .where("show_in_sidebar_filter_settings.key": "projekt_feature.general.show_in_sidebar_filter", "show_in_sidebar_filter_settings.value": "active")
  }

  scope :with_active_feature, ->(projekt_feature_key) {
    joins("INNER JOIN projekt_settings waf ON projekts.id = waf.projekt_id")
      .where("waf.key": "projekt_feature.#{projekt_feature_key}", "waf.value": "active")
  }

  scope :by_my_posts, ->(my_posts_switch, current_user_id) {
    return unless my_posts_switch

    where(author_id: current_user_id)
  }

  scope :last_week, -> { where("projekts.created_at >= ?", 7.days.ago) }

  scope :sort_by_individual_list, -> {
    individual_list
  }

  scope :with_published_custom_page, -> {
    joins(:page)
      .where(site_customization_pages: { status: "published" })
  }

  def self.includes_children_projekts_with(*sub_relations)
    includes(
      children: [*sub_relations, {children: [*sub_relations]}]
    )
  end

  def self.overview_page
    find_by(
      special_name: "projekt_overview_page",
      special: true
    )
  end

  def self.with_pm_permission_to(permission, projekt_manager)
    joins(:projekt_manager_assignments)
      .where("projekt_manager_assignments.projekt_manager_id = ? AND ? = ANY(projekt_manager_assignments.permissions)", projekt_manager.id, permission)
  end

  def self.selectable_in_selector(controller_name, current_user)
    includes(:individual_group_values, :projekt_settings, { proposal_phases: [:individual_group_values, :settings] })
      .includes_children_projekts_with(:individual_group_values, :proposal_phases, :individual_group_values, :projekt_settings, :hard_individual_group_values)
      .includes({ parent: :individual_group_values }, { top_level_projekt: :hard_individual_group_values })
      .select do |projekt|
        (!projekt.hidden_for?(current_user) || projekt.all_parent_projekts.none? { |p| p.hidden_for?(current_user) }) &&
        (projekt.can_assign_resources?(controller_name, current_user) ||
          projekt.all_children_projekts.any? do |p|
            p.can_assign_resources?(controller_name, current_user)
          end
        )
      end
  end

  def can_filter_proposals?
    proposal_phases.any?(&:current?) || base_selection_proposals.any?
  end

  def can_filter_debates?
    debate_phases.any?(&:current?) || debates.any?
  end

  def projekt_phases_for(resource)
    return debate_phases if resource.is_a?(Debate)
    return proposal_phases if resource.is_a?(Proposal)
    return voting_phases if resource.is_a?(Poll)
    return legislation_phases if resource.is_a?(Legislation::Process)
  end

  def published?
    page&.status == "published"
  end

  def update_page
    update_corresponding_page if name_changed?
    yield
  end

  def can_assign_resources?(controller_name, user)
    return false if user.nil?
    return false unless activated?

    if controller_name == "proposals"
      if proposal_phases.any?(&:selectable_by_admins_only?) && !user.can_manage_projekt?(self)
        false
      else
        proposal_phases.any_selectable?(user)
      end

    elsif controller_name == "debates"
      if debate_phases.any?(&:selectable_by_admins_only?) && !user.can_manage_projekt?(self)
        false
      else
        debate_phases.any_selectable?(user)
      end

    elsif controller_name == "polls"
      voting_phases.any_selectable?(user)

    elsif controller_name == "processes"
      legislation_phases
        .reject { |lp| lp.legislation_process.present? || !lp.selectable_by?(user) }
        .any?
    end
  end

  def top_level?
    order_number.present? && parent.blank?
  end

  def current?(timestamp = Time.zone.today)
    activated? &&
     (total_duration_start.blank? || total_duration_start <= timestamp) &&
     (total_duration_end.blank? || total_duration_end >= timestamp)
  end

  def expired?(timestamp = Time.zone.today)
    activated? &&
      total_duration_end.present? &&
      total_duration_end < timestamp
  end

  # def activated?
  #   projekt_settings.
  #     find_by(projekt_settings: { key: "projekt_feature.main.activate" }).
  #     value.
  #     present?
  # end
  def projekt_settings_hash
    @projekt_settings ||= projekt_settings.reload.pluck(:key, :value).to_h
  end

  def activated?
    projekt_settings_hash["projekt_feature.main.activate"].present?
  end

  def activated_children
    children.activated
  end

  def calculate_level(counter = 1)
    return counter if parent.blank?

    parent.calculate_level(counter + 1)
  end

  def breadcrumb_trail_ids(breadcrumb_trail_ids = [])
    breadcrumb_trail_ids.unshift(id)

    parent.breadcrumb_trail_ids(breadcrumb_trail_ids) if parent.present?

    breadcrumb_trail_ids
  end

  def all_parent_ids
    all_parent_projekts.map(&:id)
  end

  def all_parent_projekts
    [parent, top_level_projekt].compact
  end

  def all_children_ids
    all_children_projekts.map(&:id)
  end

  def all_children_projekts
    # [*children, *third_level_children].compact
    [*children, *children.map(&:children).flatten].compact
  end

  def has_active_phase?(controller_name)
    case controller_name
    when "proposals"
      proposal_phases.any?(&:current?)
    when "debates"
      debate_phases.any?(&:current?)
    when "polls"
      false
    end
  end

  def top_parent
    return self if parent.blank?

    parent.top_parent
  end

  def siblings
    if parent.present?
      parent.children
    else
      Projekt.top_level
    end
  end

  def order_up
    set_order && return if order_number.blank?
    return if order_number == 1

    swap_order_numbers_up
    ensure_projekt_order_integrity
  end

  def order_down
    set_order && return if order_number.blank?
    return if order_number > siblings.maximum(:order_number)

    swap_order_numbers_down
    ensure_projekt_order_integrity
  end

  def self.ensure_order_integrity
    all.find_each do |projekt|
      projekt.send(:ensure_projekt_order_integrity)
    end
  end

  def create_default_settings
    ProjektSetting.defaults.each do |name, value|
      unless ProjektSetting.find_by(key: name, projekt_id: id)
        ProjektSetting.create!(key: name, value: value, projekt_id: id)
      end
    end
  end

  def title
    name
  end

  def legislation_process
    legislation_processes.order(:updated_at).last
  end

  def overview_page?
    special? && (special_name == OVERVIEW_PAGE_NAME)
  end

  def name
    if overview_page?
      I18n.t("custom.projekts.overview_page.projekt_name")
    else
      super
    end
  end

  def name_for_resource_creation(resource)
    if overview_page?
      resource_name = resource.class.name.downcase

      I18n.t(
        "custom.projekts.overview_page.projekt_name_for_#{resource_name}",
        default: name
      )
    else
      page.title
    end
  end

  def all_ids_in_tree
    all_parent_ids + [id] + all_children_ids
  end

  def all_projekt_labels
    ProjektLabel.where(projekt_id: (all_parent_ids + [id]))
  end

  def all_projekt_labels_in_tree
    ProjektLabel.where(projekt_id: all_ids_in_tree)
  end

  def visible_for?(user = nil)
    return true if user.present? && user.administrator?
    return true if user.present? && user.projekt_manager?(self)
    return false unless activated?

    if hard_individual_group_values.empty?
      true
    else
      user.present? && (hard_individual_group_values.ids & user.individual_group_values.ids).any?
    end
  end

  def hidden_for?(user = nil)
    !visible_for?(user)
  end

  def comments_allowed?(user = nil)
    true
  end

  def vc_map_enabled?
    projekt_settings.find_by(key: "projekt_feature.general.vc_map_enabled")&.enabled?
  end

  def self.available_filters(all_projekts)
    return [] if all_projekts.blank?

    projekts_count_hash = {}
    INDEX_FILTERS.each do |order|
      projekts_count_hash[order] = all_projekts.send(order).count
    end

    projekts_count_hash.select { |_, value| value > 0 }.keys
  end

  def current_phases
    projekt_phases.select(&:current?)
  end

  def self.transfer_description_to_page_subtitle
    all.find_each do |p|
      p.translations.each do |t|
        next unless p.page.translations.find_by(locale: t.locale).present?

        p.page.translations.find_by(locale: t.locale).update!(subtitle: t.description)
      end
    end
  end

  def self.transfer_image_to_page
    all.find_each do |p|
      projekt_image = p.image
      next unless projekt_image.present?

      p.page.image = projekt_image
    end
  end

  private

    def create_corresponding_page
      page = SiteCustomization::Page.new(
        title: name,
        slug: form_page_slug,
        status: "published",
        projekt: self,
        content: ""
      )

      if page.save
        self.page = page
      end
    end

    def update_corresponding_page
      page.update(title: name, slug: form_page_slug)
    end

    def form_page_slug
      clean_slug = name.downcase.gsub("ä", "ae").gsub("ö", "oe").gsub("ü", "ue").gsub("ß", "ss")
        .gsub(/[^a-z0-9\s]/, "").gsub(/\s+/, "-")
      pages_with_similar_slugs = SiteCustomization::Page.where("slug ~ ?", "^#{clean_slug}(-[0-9]+$|$)")
        .order(id: :asc)

      if pages_with_similar_slugs.any? && pages_with_similar_slugs.last.slug.match?(/-\d+$/)
        clean_slug + "-" + (pages_with_similar_slugs.last.slug.split("-")[-1].to_i + 1).to_s
      elsif pages_with_similar_slugs.any?
        clean_slug + "-2"
      else
        clean_slug
      end
    end

    def set_order
      return unless order_number.blank?

      if siblings.with_order_number.any? &&
          siblings.with_order_number.pluck(:order_number).first == 1 &&
          siblings.with_order_number.pluck(:order_number).each_cons(2).all? { |a, b| b == a + 1 }
        ordered_siblings_count = siblings.with_order_number.last.order_number
        update!(order_number: ordered_siblings_count + 1)
      elsif siblings.with_order_number.any?
        update!(order_number: 0)
        ensure_projekt_order_integrity
      else
        update!(order_number: 1)
      end
    end

    def swap_order_numbers_up
      if siblings.with_order_number.where("order_number < ?", order_number).any?
        preceding_sibling_order_number = siblings.with_order_number.where("order_number < ?", order_number)
          .last.order_number
        preceding_sibling = siblings.find_by(order_number: preceding_sibling_order_number)

        preceding_sibling.update!(order_number: order_number)
        update!(order_number: preceding_sibling_order_number)
      end
    end

    def swap_order_numbers_down
      if siblings.with_order_number.where("order_number > ?", order_number).any?
        following_sibling_order_number = siblings.with_order_number.where("order_number > ?", order_number)
          .first.order_number
        following_sibling = siblings.find_by(order_number: following_sibling_order_number)

        following_sibling.update!(order_number: order_number)
        update!(order_number: following_sibling_order_number)
      end
    end

    def ensure_projekt_order_integrity
      unless siblings.with_order_number.pluck(:order_number).first == 1 &&
          siblings.with_order_number.pluck(:order_number).each_cons(2).all? { |a, b| b == a + 1 }
        new_order = 1
        siblings.with_order_number.each do |projekt|
          projekt.update!(order_number: new_order)
          new_order += 1
        end
      end
    end

    def create_map_location
      unless map_location.present?
        MapLocation.create!(
          latitude: Setting["map.latitude"],
          longitude: Setting["map.longitude"],
          zoom: Setting["map.zoom"],
          projekt_id: id
        )
      end
    end

    def set_default_color
      self.color ||= "#004a83"
    end

    def touch_updated_at(geozone)
      touch if persisted?
    end

    def assign_top_level_projekt_from_parent
      return unless parent_id_changed?

      if parent&.parent_id.present?
        self.top_level_projekt_id = parent.parent_id
      end
    end
end
