class ProjektsController < ApplicationController
  skip_authorization_check
  has_orders %w[active all ongoing upcoming expired], only: :index

  before_action do
    raise FeatureFlags::FeatureDisabled, :projekts_overview unless Setting['projekts.overview_page']
  end

  include ProjektControllerHelper

  def index
    @filtered_goals = params[:sdg_goals].present? ? params[:sdg_goals].split(',').map{ |code| code.to_i } : nil
    @filtered_targets = params[:sdg_targets].present? ? params[:sdg_targets].split(',')[0] : nil

    @projekts =
      Projekt
        .joins( 'INNER JOIN projekt_settings show_in_overview_page ON projekts.id = show_in_overview_page.projekt_id' )
        .where( 'show_in_overview_page.key': 'projekt_feature.general.show_in_overview_page', 'show_in_overview_page.value': 'active' )

    @projekts_count_hash = {}

    valid_orders.each do |order|
      @projekts_count_hash[order] = @projekts.send(order).count
    end

    @current_active_orders = @projekts_count_hash.select do |key, value|
      value > 0
    end.keys

    @current_order = valid_orders.include?(params[:order]) ? params[:order] : @current_active_orders.first

    @geozones = Geozone.all
    @selected_geozone_affiliation = params[:geozone_affiliation] || 'all_resources'
    @affiliated_geozones = (params[:affiliated_geozones] || '').split(',').map(&:to_i)

    @selected_geozone_restriction = params[:geozone_restriction] || 'no_restriction'
    @restricted_geozones = (params[:restricted_geozones] || '').split(',').map(&:to_i)

    unless params[:search].present?
      take_only_by_tag_names
      take_by_projekts
      take_by_sdgs
      take_by_geozone_affiliations
      take_by_geozone_restrictions
      take_by_my_posts
    end

    @categories = @projekts.map { |p| p.tags.category }.flatten.uniq.compact.sort
    @tag_cloud = tag_cloud
    @selected_tags = all_selected_tags
    @resource_name = 'projekt'

    @projekts = @projekts.includes(:sdg_goals).send(@current_order)
    @sdgs = (@projekts.map(&:sdg_goals).flatten.uniq.compact + SDG::Goal.where(code: @filtered_goals).to_a).uniq
    @sdg_targets = (@projekts.map(&:sdg_targets).flatten.uniq.compact + SDG::Target.where(code: @filtered_targets).to_a).uniq

    @projekts_coordinates = all_projekts_map_locations(@projekts)
  end

  def show
    projekt = Projekt.find(params[:id])

    redirect_to page_path(projekt.page.slug) if projekt.present?
  rescue
    head 404, content_type: "text/html"
  end

  def update_selected_parent_projekt
    selected_parent_projekt_id = get_highest_unique_parent_projekt_id(params[:selected_projekts_ids])
    render json: {selected_parent_projekt_id: selected_parent_projekt_id }
  end

  def json_data
    projekt = Projekt.find(params[:id])
    data = {
      projekt_id: projekt.id,
      projekt_title: projekt.title
    }.to_json

    respond_to do |format|
      format.json { render json: data }
    end
  end

  private

  def take_only_by_tag_names
    if params[:tags].present?
      @projekts = @projekts.tagged_with(params[:tags].split(","), all: true)
    end
  end

  def take_by_projekts
    if params[:filter_projekt_ids].present?
      @projekts = @projekts.where(projekt_id: params[:filter_projekt_ids]).distinct
    end
  end

  def take_by_sdgs
    if params[:sdg_targets].present?
      sdg_target_codes = params[:sdg_targets].split(',')
      @projekts = @projekts.left_joins(sdg_global_targets: :local_targets)

      @projekts = @projekts.where(sdg_targets: { code: sdg_target_codes}).or(@projekts.where(sdg_local_targets: { code: sdg_target_codes })).distinct
      return
    end

    if params[:sdg_goals].present?
      @projekts = @projekts.joins(:sdg_goals).where(sdg_goals: { code: params[:sdg_goals].split(',') }).distinct
    end
  end

  def take_by_geozone_affiliations
    case @selected_geozone_affiliation
    when 'all_resources'
      @projekts
    when 'no_affiliation'
      @projekts = @projekts.where(geozone_affiliated: 'no_affiliation').distinct
    when 'entire_city'
      @projekts = @projekts.where(geozone_affiliated: 'entire_city').distinct
    when 'only_geozones'
      @projekts = @projekts.where(geozone_affiliated: 'only_geozones').distinct
      if @affiliated_geozones.present?
        @projekts = @projekts.joins(:geozone_affiliations).where(geozones: { id: @affiliated_geozones }).distinct
      else
        @projekts = @projekts.joins(:geozone_affiliations).where.not(geozones: { id: nil }).distinct
      end
    end
  end

  def take_by_geozone_restrictions
    case @selected_geozone_restriction
    when 'no_restriction'
      @projekts = @projekts.joins(:proposal_phase).distinct
    when 'only_citizens'
      @projekts = @projekts.joins(:proposal_phase).where(projekt_phases: { geozone_restricted: ['only_citizens', 'only_geozones'] }).distinct
    when 'only_geozones'
      @projekts = @projekts.joins(:proposal_phase).where(projekt_phases: { geozone_restricted: 'only_geozones' }).distinct

      if @restricted_geozones.present?
        sql_query = "
            INNER JOIN projekt_phases AS proposal_phases_proposals_join_for_restrictions ON proposal_phases_proposals_join_for_restrictions.projekt_id = projekts_proposals_join_for_restrictions.id AND proposal_phases_proposals_join_for_restrictions.type IN ('ProjektPhase::ProposalPhase')
            INNER JOIN projekt_phase_geozones ON projekt_phase_geozones.projekt_phase_id = proposal_phases_proposals_join_for_restrictions.id
            INNER JOIN geozones AS geozone_restrictions ON geozone_restrictions.id = projekt_phase_geozones.geozone_id
            "
            @projekts = @projekts.joins(sql_query).where(geozone_restrictions: { id: @restricted_geozones }).distinct
      end
    end
  end

  def take_by_my_posts
    if params[:my_posts_filter] == 'true'
      @projekts = @projekts.by_author(current_user&.id)
    end
  end

  def tag_cloud
    TagCloud.new(Projekt.all, params[:tags])
  end
end
