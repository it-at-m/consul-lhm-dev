class ProjektsController < ApplicationController
  include CustomHelper
  include ProposalsHelper

  skip_authorization_check
  has_orders %w[index_order_underway index_order_all
                index_order_ongoing index_order_upcoming
                index_order_expired index_order_individual_list], only: [
    :index, :comment_phase_footer_tab, :debate_phase_footer_tab,
    :proposal_phase_footer_tab, :voting_phase_footer_tab
  ]

  before_action :find_overview_page_projekt, only: [
    :index, :comment_phase_footer_tab, :debate_phase_footer_tab,
    :proposal_phase_footer_tab, :voting_phase_footer_tab
  ]

  before_action :select_projekts, only: [
    :index, :comment_phase_footer_tab, :debate_phase_footer_tab,
    :proposal_phase_footer_tab, :voting_phase_footer_tab
  ]

  before_action :raise_flag_feature_disabled, except: [:map_html]

  include ProjektControllerHelper

  def index
    @projekts_overview_page_navigation_settings = Setting.all.select { |setting| setting.key.start_with?('extended_feature.projekts_overview_page_navigation') }
    @projekts_overview_page_footer_settings = Setting.all.select { |setting| setting.key.start_with?('extended_feature.projekts_overview_page_footer') }

    @top_level_active_projekts = @projekts
    @top_level_archived_projekts = @projekts

    @current_phase = find_current_phase(params[:selected_phase_id])

    @show_footer = Setting["extended_feature.projekts_overview_page_footer.show_in_#{@current_order}"]

    if @current_phase.present?
      send("set_#{@current_phase.resources_name}_footer_tab_variables", @overview_page_special_projekt)
    end

    @comments_count = @overview_page_special_projekt.comments.count
    @debates_count = Debate.where(projekt_id: @overview_page_special_projekt.id).count
    @proposals_count = Proposal.base_selection.where(projekt_id: @overview_page_special_projekt.id).count
    @polls_count = Poll.base_selection.where(projekt_id: @overview_page_special_projekt.id).count
  end

  def find_current_phase(default_phase_id)
    default_phase_id ||= ProjektSetting.find_by(projekt: @overview_page_special_projekt, key: 'projekt_custom_feature.default_footer_tab').value

    if default_phase_id.present?
      projekt_phase = ProjektPhase.find(default_phase_id)

      if projekt_phase.phase_activated?
        return projekt_phase
      end
    end

    if @overview_page_special_projekt.projekt_phases.select { |phase| phase.phase_activated? }.any?
      @overview_page_special_projekt.projekt_phases.select { |phase| phase.phase_activated? }.first
    else
      @overview_page_special_projekt.comment_phase
    end
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

  def comment_phase_footer_tab
    set_comments_footer_tab_variables

    respond_to do |format|
      format.js { render "projekts/projekt_overview_footer/footer_tab" }
    end
  end

  def debate_phase_footer_tab
    set_debates_footer_tab_variables

    respond_to do |format|
      format.js { render "projekts/projekt_overview_footer/footer_tab" }
    end
  end

  def proposal_phase_footer_tab
    set_proposals_footer_tab_variables

    respond_to do |format|
      format.js { render "projekts/projekt_overview_footer/footer_tab" }
    end
  end

  def voting_phase_footer_tab
    set_polls_footer_tab_variables

    respond_to do |format|
      format.js { render "pages/projekt_footer/footer_tab" }
    end
  end

  def map_html
    @projekt = Projekt.find(params[:id])
  end

  private

  def set_comments_footer_tab_variables(projekt = nil)
    @valid_orders = %w[most_voted newest oldest]
    @current_order = @valid_orders.include?(params[:order]) ? params[:order] : @valid_orders.first

    @current_tab_phase = @overview_page_special_projekt.comment_phase
    params[:current_tab_path] = 'comment_phase_footer_tab'

    @commentable = @overview_page_special_projekt
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
    set_comment_flags(@comment_tree.comments)
  end

  def set_debates_footer_tab_variables(projekt=nil)
    @current_projekt = @overview_page_special_projekt
    @current_tab_phase = @current_projekt.debate_phase
    @selected_parent_projekt = @current_projekt
    params[:current_tab_path] = 'debate_phase_footer_tab'

    @current_order = if @valid_orders.include?(params[:order])
                       params[:order]
                     elsif helpers.projekt_feature?(@current_projekt, 'general.set_default_sorting_to_newest')
                       'created_at'
                     else
                       Setting["selectable_setting.debates.default_order"]
                     end

    set_resources(Debate)

    @top_level_active_projekts = @resources
    @top_level_archived_projekts = @resources

    @debates = @resources.page(params[:page]) #.send("sort_by_#{@current_order}")
    # @debate_votes = current_user ? current_user.debate_votes(@debates) : {}
  end

  def set_proposals_footer_tab_variables(projekt=nil)
    @current_tab_phase = @current_projekt.proposal_phase
    params[:current_tab_path] = 'proposal_phase_footer_tab'

    @selected_parent_projekt = @current_projekt

    set_resources(Proposal)

    @proposals_coordinates = all_proposal_map_locations(@resources)
    @proposals = @resources.page(params[:page]) #.send("sort_by_#{@current_order}")
  end

  def set_polls_footer_tab_variables(projekt=nil)
    @valid_filters = %w[all current]
    @current_filter = @valid_filters.include?(params[:filter]) ? params[:filter] : @valid_filters.first

    # @current_projekt = projekt || SiteCustomization::Page.find_by(slug: params[:id]).projekt
    @current_tab_phase = @current_projekt.voting_phase
    params[:current_tab_path] = 'voting_phase_footer_tab'

    @selected_parent_projekt = @current_projekt

    @resources = Poll
      .created_by_admin
      .not_budget
      .where(projekt_id: @overview_page_special_projekt.id)
      .includes(:geozones)

    @polls = Kaminari.paginate_array(@resources.sort_for_list).page(params[:page])
  end

  def set_resources(resource_model)
    # @resources = resource_model.where(projekt_id: @overview_page_special_projekt.map(&:id))
    @resources = resource_model.where(projekt_id: @overview_page_special_projekt.id)

    @resources = @current_order == "recommendations" && current_user.present? ? @resources.recommendations(current_user) : @resources.for_render
    @resources = @resources.search(@search_terms) if @search_terms.present?
    @resources = @resources.filter_by(@advanced_search_terms)
  end

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

  def find_overview_page_projekt
    @overview_page_special_projekt = Projekt.unscoped.find_by(special: true, special_name: 'projekt_overview_page')
    @current_projekt = @overview_page_special_projekt
  end

  def select_projekts
    @filtered_goals = params[:sdg_goals].present? ? params[:sdg_goals].split(',').map{ |code| code.to_i } : nil
    @filtered_targets = params[:sdg_targets].present? ? params[:sdg_targets].split(',')[0] : nil

    @projekts = Projekt.regular
    @resources = @projekts

    @projekts_count_hash = {}

    valid_orders.each do |order|
      @projekts_count_hash[order] = @projekts.send(order).count
    end

    @current_active_orders = @projekts_count_hash.select do |key, value|
      value > 0
    end.keys

    @current_order = valid_orders.include?(params[:order]) ? params[:order] : @current_active_orders.first
    @current_projekts_order = @current_order

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

    @projekts =
      @projekts
        .with_published_custom_page
        .send(@current_order)

    @map_coordinates = all_projekts_map_locations(@projekts)

    if @projekts.is_a?(Array)
      @projekts = Kaminari.paginate_array(@projekts).page(params[:page]).per(25)
    else
      @projekts = @projekts.page(params[:page]).per(25)
    end

    @sdgs = (@projekts.map(&:sdg_goals).flatten.uniq.compact + SDG::Goal.where(code: @filtered_goals).to_a).uniq
    @sdg_targets = (@projekts.map(&:sdg_targets).flatten.uniq.compact + SDG::Target.where(code: @filtered_targets).to_a).uniq

    # if @overview_page_special_projekt.proposal_phase.phase_activated?
    #   proposals = Proposal.where(projekt_id: @overview_page_special_projekt.id)
    #    @map_coordinates = @map_coordinates + all_proposal_map_locations(proposals)
    # end
  end

  def raise_flag_feature_disabled
    raise FeatureFlags::FeatureDisabled, :projekts_overview unless Setting["extended_feature.projekts_overview_page_navigation.show_in_navigation"]
  end
end
