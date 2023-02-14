require_dependency Rails.root.join("app", "models", "proposal").to_s
class Proposal < ApplicationRecord
  include Labelable

  belongs_to :projekt, optional: true, touch: true
  has_one :proposal_phase, through: :projekt
  has_many :geozone_restrictions, through: :proposal_phase
  has_many :geozone_affiliations, through: :projekt

  delegate :votable_by?, to: :proposal_phase
  delegate :comments_allowed?, to: :proposal_phase

  validates_translation :description, presence: true
  validates :projekt_id, presence: true
  validate :description_sanitized

  scope :with_current_projekt, -> { joins(:projekt).merge(Projekt.current) }
  scope :by_author, ->(user_id) {
    return if user_id.nil?

    where(author_id: user_id)
  }

  scope :sort_by_alphabet, -> {
    with_translations(I18n.locale).
    select("proposals.*, LOWER(proposal_translations.title)").
    reorder("LOWER(proposal_translations.title) ASC")
  }
  scope :sort_by_votes_up, -> { reorder(cached_votes_up: :desc) }

  scope :seen,                     -> { where.not(ignored_flag_at: nil) }
  scope :unseen,                   -> { where(ignored_flag_at: nil) }

  alias_attribute :projekt_phase, :proposal_phase

  def self.proposals_orders(user = nil)
    orders = %w[hot_score created_at alphabet votes_up random]
    # orders << "recommendations" if Setting["feature.user.recommendations_on_proposals"] && user&.recommended_proposals
    orders
  end

  def self.scoped_projekt_ids_for_index
    Projekt.top_level
      .map{ |p| p.all_children_projekts.unshift(p) }
      .flatten.select do |projekt|
        ProjektSetting.find_by( projekt: projekt, key: 'projekt_feature.main.activate').value.present? &&
        ProjektSetting.find_by( projekt: projekt, key: 'projekt_feature.proposals.show_in_sidebar_filter').value.present? &&
        projekt.all_children_projekts.unshift(projekt).any? { |p| p.proposal_phase.current? || p.proposals.base_selection.any? }
      end
      .pluck(:id)
  end

  def self.scoped_projekt_ids_for_footer(projekt)
    projekt.top_parent.all_children_projekts.unshift(projekt.top_parent).select do |projekt|
      ProjektSetting.find_by( projekt: projekt, key: 'projekt_feature.main.activate').value.present? &&
      projekt.all_children_projekts.unshift(projekt).any? { |p| p.proposal_phase.current? || p.proposals.base_selection.any? }
    end.pluck(:id)
  end

  def self.base_selection
    published.
      not_archived.
      not_retired
  end

  def successful?
    total_votes >= custom_votes_needed_for_success
  end

  def self.successful
    ids = Proposal.select { |p| p.cached_votes_up >= p.custom_votes_needed_for_success }.pluck(:id)
    Proposal.where(id: ids)
	end

  def self.unsuccessful
    ids = Proposal.select { |p| p.cached_votes_up < p.custom_votes_needed_for_success }.pluck(:id)
    Proposal.where(id: ids)
	end

  def description_sanitized
    sanitized_description = ActionController::Base.helpers.strip_tags(description).gsub("\n", '').gsub("\r", '').gsub(" ", '').gsub(/^$\n/, '').gsub(/[\u202F\u00A0\u2000\u2001\u2003]/, "")
    errors.add(:description, :too_long, message: 'too long text') if
      sanitized_description.length > Setting[ "extended_option.proposals.description_max_length"].to_i
  end

  def custom_votes_needed_for_success
    return Proposal.votes_needed_for_success unless projekt.present?
    return Proposal.votes_needed_for_success if ProjektSetting.find_by(projekt: projekt, key: "projekt_feature.proposal_options.votes_for_proposal_success").value.to_i == 0
    ProjektSetting.find_by(projekt: projekt, key: "projekt_feature.proposal_options.votes_for_proposal_success").value.to_i
  end

  def publish
    update!(published_at: Time.current)
    NotificationServices::NewProposalNotifier.new(id).call
    send_new_actions_notification_on_published
  end

  protected

    def set_responsible_name
      self.responsible_name = 'unregistriered'
    end
end
