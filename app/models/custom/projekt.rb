class Projekt < ApplicationRecord
  include Milestoneable
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases
  include Mappable

  has_many :children, class_name: 'Projekt', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'Projekt', optional: true

  has_many :debates, dependent: :nullify
  has_many :proposals, dependent: :nullify
  has_many :polls, dependent: :nullify

  has_one :page, class_name: "SiteCustomization::Page", dependent: :destroy

  has_many :projekt_phases, dependent: :destroy
  has_one :debate_phase, class_name: 'ProjektPhase::DebatePhase'
  has_one :proposal_phase, class_name: 'ProjektPhase::ProposalPhase'
  has_many :geozone_limitations, through: :projekt_phases
  has_and_belongs_to_many :geozone_affiliations, through: :geozones_projekts, class_name: 'Geozone'

  has_many :projekt_settings, dependent: :destroy
  has_many :projekt_notifications, dependent: :destroy

  has_many :comments, as: :commentable, inverse_of: :commentable, dependent: :destroy
  belongs_to :author, -> { with_hidden }, class_name: "User", inverse_of: :projekts

  accepts_nested_attributes_for :debate_phase, :proposal_phase, :projekt_notifications

  after_create :create_corresponding_page, :set_order, :create_projekt_phases, :create_default_settings, :create_map_location
  after_destroy :ensure_order_integrity

  scope :top_level, -> { where(parent: nil) }
  scope :with_order_number, -> { where.not(order_number: nil).order(order_number: :asc) }

  scope :top_level_active, -> { top_level.with_order_number.where( "total_duration_end IS NULL OR total_duration_end >= ?", Date.today).joins(:projekt_settings).where( projekt_settings: { key: 'projekt_feature.main.activate', value: 'active' }) }
  scope :top_level_archived, -> { top_level.with_order_number.where( "total_duration_end < ?", Date.today).joins(:projekt_settings).where( projekt_settings: { key: 'projekt_feature.main.activate', value: '' }) }

  scope :top_level_active_top_menu, -> { top_level.with_order_number.
                                         where("total_duration_end IS NULL OR total_duration_end >= ?", Date.today).
                                         joins('INNER JOIN projekt_settings a ON projekts.id = a.projekt_id').
                                         joins('INNER JOIN projekt_settings b ON projekts.id = b.projekt_id').
                                         where("a.key": "projekt_feature.main.activate", "a.value": "active", "b.key": "projekt_feature.general.show_in_navigation", "b.value": "active").distinct }

  def all_children_ids(all_children_ids = [])
    if self.children.any?
      self.children.each do |child|
        all_children_ids.push(child.id)
        child.all_children_ids(all_children_ids)
      end
    end

    all_children_ids
  end

  def top_level?
    self.parent.blank?
  end

  def top_parent
    return self if self.parent.blank?
    self.parent.top_parent
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
    ensure_order_integrity
  end

  def order_down
    set_order && return if order_number.blank?
    return if order_number > siblings.maximum(:order_number)
    swap_order_numbers_down
    ensure_order_integrity
  end

  def update_order
    unless siblings.with_order_number.pluck(:order_number).first == 1 && siblings.with_order_number.pluck(:order_number).each_cons(2).all? { |a, b| b == a + 1 }
      update(order_number: nil)
      set_order
    end
  end

  def create_default_settings
    ProjektSetting.defaults.each do |name, value|
      unless ProjektSetting.find_by(key: name, projekt_id: self.id)
        ProjektSetting.create(key: name, value: value, projekt_id: self.id)
      end
    end
  end

  def self.ensure_projekt_phases
    all.each do |projekt|
      projekt.debate_phase = ProjektPhase::DebatePhase.create unless projekt.debate_phase
      projekt.proposal_phase = ProjektPhase::ProposalPhase.create unless projekt.proposal_phase
    end
  end

  def title
    name
  end

  private

  def create_corresponding_page
    page_title = self.name
    clean_slug = self.name.downcase.gsub(/[^a-z0-9\s]/, '').gsub(/\s+/, '-')
    pages_with_similar_slugs = SiteCustomization::Page.where("slug ~ ?", "^#{clean_slug}(-[0-9]+$|$)").order(id: :asc)

    if pages_with_similar_slugs.any? && pages_with_similar_slugs.last.slug.match?(/-\d+$/)
      page_slug = clean_slug + '-' + (pages_with_similar_slugs.last.slug.split('-')[-1].to_i + 1).to_s
    elsif pages_with_similar_slugs.any?
      page_slug = clean_slug + '-2'
    else
      page_slug = clean_slug
    end
    page = SiteCustomization::Page.new(title: page_title, slug: page_slug, projekt: self)
    
    if page.save
      self.page = page
    end
  end

  def set_order
    if self.siblings.with_order_number.any?
      ordered_siblings_count = self.siblings.with_order_number.last.order_number
      self.update(order_number: ordered_siblings_count + 1)
    else
      self.update(order_number: 1)
    end
  end

  def create_projekt_phases
    self.debate_phase = ProjektPhase::DebatePhase.create
    self.proposal_phase = ProjektPhase::ProposalPhase.create
  end

  def swap_order_numbers_up
    if siblings.with_order_number.where("order_number < ?", order_number).any?
      preceding_sibling_order_number = siblings.with_order_number.where("order_number < ?", order_number).last.order_number
      preceding_sibling = siblings.find_by(order_number: preceding_sibling_order_number)

      preceding_sibling.update(order_number: order_number)
      self.update(order_number: preceding_sibling_order_number)     
    end
  end

  def swap_order_numbers_down
    if siblings.with_order_number.where("order_number > ?", order_number).any?
      following_sibling_order_number = siblings.with_order_number.where("order_number > ?", order_number).first.order_number
      following_sibling = siblings.find_by(order_number: following_sibling_order_number)

      following_sibling.update(order_number: order_number)
      self.update(order_number: following_sibling_order_number)     
    end
  end

  def ensure_order_integrity
    unless siblings.with_order_number.pluck(:order_number).first == 1 && siblings.with_order_number.pluck(:order_number).each_cons(2).all? { |a, b| b == a + 1 }
      new_order = 1
      siblings.with_order_number.each do |projekt|
        projekt.update(order_number: new_order)
        new_order += 1
      end
    end
  end

  def create_map_location
    unless map_location.present?
      MapLocation.create(
        latitude: Setting['map.latitude'],
        longitude: Setting['map.longitude'],
        zoom: Setting['map.zoom'],
        projekt_id: self.id
      )
    end
  end
end
