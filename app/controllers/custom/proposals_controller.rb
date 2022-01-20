require_dependency Rails.root.join("app", "controllers", "proposals_controller").to_s

class ProposalsController

  include ProposalsHelper
  include ProjektControllerHelper

  before_action :process_tags, only: [:create, :update]
  before_action :set_projekts_for_selector, only: [:new, :edit, :create, :update]

  def index_customization
    @filtered_goals = params[:sdg_goals].present? ? params[:sdg_goals].split(',').map{ |code| code.to_i } : nil
    @filtered_target = params[:sdg_targets].present? ? params[:sdg_targets].split(',')[0] : nil

    if params[:projekts]
      @selected_projekts_ids = params[:projekts].split(',').select{ |id| Projekt.find_by(id: id).present? }
      selected_parent_projekt_id = get_highest_unique_parent_projekt_id(@selected_projekts_ids)
      @selected_parent_projekt = Projekt.find_by(id: selected_parent_projekt_id)
    end

    @geozones = Geozone.all

    @selected_geozone_affiliation = params[:geozone_affiliation] || 'all_resources'
    @affiliated_geozones = (params[:affiliated_geozones] || '').split(',').map(&:to_i)

    @selected_geozone_restriction = params[:geozone_restriction] || 'no_restriction'
    @restricted_geozones = (params[:restricted_geozones] || '').split(',').map(&:to_i)

    discard_draft
    discard_archived
    load_retired
    load_selected
    load_featured
    remove_archived_from_order_links
    remove_where_projekt_not_active

    unless params[:search].present?
      take_only_by_tag_names
      take_by_projekts
      take_by_sdgs
      take_by_geozone_affiliations
      take_by_geozone_restrictions
    end

    @proposals_coordinates = all_proposal_map_locations(@resources)
    @selected_tags = all_selected_tags

    @top_level_active_projekts = Projekt.top_level.active.selectable_in_sidebar_active('proposals')
    @top_level_archived_projekts = Projekt.top_level.archived.selectable_in_sidebar_archived('proposals')
  end

  def new
    redirect_to proposals_path if proposal_limit_exceeded?(current_user)
    redirect_to proposals_path if Projekt.top_level.selectable_in_selector('proposals', current_user).empty?

    @resource = resource_model.new
    set_geozone
    set_resource_instance
    @selected_projekt = Projekt.find(params[:projekt]) if params[:projekt]
  end

  def edit
    @selected_projekt = @proposal.projekt.id
  end

  def show
    super
    @projekt = @proposal.projekt
    @notifications = @proposal.notifications
    @notifications = @proposal.notifications.not_moderated
    @related_contents = Kaminari.paginate_array(@proposal.relationed_contents)
                                .page(params[:page]).per(5)

    if request.path != proposal_path(@proposal)
      redirect_to proposal_path(@proposal), status: :moved_permanently
    end

    @affiliated_geozones = (params[:affiliated_geozones] || '').split(',').map(&:to_i)
    @restricted_geozones = (params[:restricted_geozones] || '').split(',').map(&:to_i)
  end

  def unvote
    @follow = Follow.find_by(user: current_user, followable: @proposal)
    @follow.destroy if @follow
    @proposal.unvote_by(current_user)
    set_proposal_votes(@proposal)
  end

  def created
    @resource_name = 'proposal'
    @affiliated_geozones = []
    @restricted_geozones = []

  end

  def flag
    Flag.flag(current_user, @proposal)
    redirect_to @proposal
  end

  def unflag
    Flag.unflag(current_user, @proposal)
    redirect_to @proposal
  end

  private

    def remove_where_projekt_not_active
      active_projekts_ids = Projekt.all.joins(:projekt_settings).where(projekt_settings: { key: 'projekt_feature.main.activate', value: 'active' }).pluck(:id)
      @resources = @resources.joins(:projekt).where(projekts: { id: active_projekts_ids })
    end

    def process_tags
      if params[:proposal][:tags]
        params[:tags] = params[:proposal][:tags].split(',')
        params[:proposal].delete(:tags)
      end

      params[:proposal][:tag_list_custom]&.split(",")&.each do |t|
        next if t.strip.blank?
        Tag.find_or_create_by name: t.strip
      end
      params[:proposal][:tag_list] ||= ""
      params[:proposal][:tag_list] += ((params[:proposal][:tag_list_predefined] || "").split(",") + (params[:proposal][:tag_list_custom] || "").split(",")).join(",")
      params[:proposal].delete(:tag_list_predefined)
      params[:proposal].delete(:tag_list_custom)
    end

    def take_only_by_tag_names
      if params[:tags].present?
        @resources = @resources.tagged_with(params[:tags].split(","), all: true)
      end
    end

    def take_by_projekts
      if params[:projekts].present?
        @resources = @resources.where(projekt_id: params[:projekts].split(',')).distinct
      end
    end

    def take_by_sdgs
      if params[:sdg_targets].present?
        @resources = @resources.joins(:sdg_global_targets).where(sdg_targets: { code: params[:sdg_targets].split(',')[0] }).distinct
        return
      end

      if params[:sdg_goals].present?
        @resources = @resources.joins(:sdg_goals).where(sdg_goals: { code: params[:sdg_goals].split(',') }).distinct
      end
    end

    def take_by_geozone_affiliations
      case @selected_geozone_affiliation
      when 'all_resources'
        @resources
      when 'no_affiliation'
        @resources = @resources.joins(:projekt).where( projekts: { geozone_affiliated: 'no_affiliation' } ).distinct
      when 'entire_city'
        @resources = @resources.joins(:projekt).where(projekts: { geozone_affiliated: 'entire_city' } ).distinct
      when 'only_geozones'
        @resources = @resources.joins(:projekt).where(projekts: { geozone_affiliated: 'only_geozones' } ).distinct
        if @affiliated_geozones.present?
          @resources = @resources.joins(:geozone_affiliations).where(geozones: { id: @affiliated_geozones }).distinct
        else
          @resources = @resources.joins(:geozone_affiliations).where.not(geozones: { id: nil }).distinct
        end
      end
    end

    def take_by_geozone_restrictions
      case @selected_geozone_restriction
      when 'no_restriction'
        @resources = @resources.joins(:proposal_phase).distinct
      when 'only_citizens'
        @resources = @resources.joins(:proposal_phase).where(projekt_phases: { geozone_restricted: ['only_citizens', 'only_geozones'] }).distinct
      when 'only_geozones'
        @resources = @resources.joins(:proposal_phase).where(projekt_phases: { geozone_restricted: 'only_geozones' }).distinct

        if @restricted_geozones.present?
          sql_query = "
            INNER JOIN projekts AS projekts_proposals_join_for_restrictions ON projekts_proposals_join_for_restrictions.hidden_at IS NULL AND projekts_proposals_join_for_restrictions.id = proposals.projekt_id
            INNER JOIN projekt_phases AS proposal_phases_proposals_join_for_restrictions ON proposal_phases_proposals_join_for_restrictions.projekt_id = projekts_proposals_join_for_restrictions.id AND proposal_phases_proposals_join_for_restrictions.type IN ('ProjektPhase::ProposalPhase')
            INNER JOIN projekt_phase_geozones ON projekt_phase_geozones.projekt_phase_id = proposal_phases_proposals_join_for_restrictions.id
            INNER JOIN geozones AS geozone_restrictions ON geozone_restrictions.id = projekt_phase_geozones.geozone_id
          "
          @resources = @resources.joins(sql_query).where(geozone_restrictions: { id: @restricted_geozones }).distinct
        end
      end
    end

    def proposal_params
      attributes = [:video_url, :responsible_name, :tag_list,
                    :terms_of_service, :geozone_id, :projekt_id, :related_sdg_list,
                    image_attributes: image_attributes,
                    documents_attributes: [:id, :title, :attachment, :cached_attachment,
                                           :user_id, :_destroy],
                    map_location_attributes: [:latitude, :longitude, :zoom]]
      translations_attributes = translation_params(Proposal, except: :retired_explanation)
      params.require(:proposal).permit(attributes, translations_attributes)
    end

    def proposal_limit_exceeded?(user)
      user.proposals.where(retired_at: nil).count >= Setting['extended_option.proposals.max_active_proposals_per_user'].to_i
    end
end
