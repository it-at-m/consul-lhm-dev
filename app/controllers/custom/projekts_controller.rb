class ProjektsController < ApplicationController
  include CustomHelper
  include ProposalsHelper

  skip_authorization_check
  before_action :raise_flag_feature_disabled, except: [:map_html]

  include ProjektControllerHelper

  def index
    @projekts = Projekt.regular.with_published_custom_page
    @all_projekts = @projekts
    @special_projekt = Projekt.unscoped.find_by(special: true, special_name: "projekt_overview_page")

    @resource_name = "projekt"

    valid_filters = %w[index_order_all index_order_underway index_order_ongoing index_order_upcoming index_order_expired index_order_individual_list]
    valid_filters.push("index_order_drafts") if current_user&.administrator? || current_user&.projekt_manager?
    @active_projekts_filters = valid_filters.select { |filter| @projekts.send(filter).count > 0 }.presence || ["index_order_all"]
    @current_projekts_filter = valid_filters.include?(params[:filter]) ? params[:filter] : @active_projekts_filters.first
    @projekts = @projekts.send(@current_projekts_filter)
    @map_coordinates = all_projekts_map_locations(@projekts.pluck(:id))


    @geozones = Geozone.all
    @selected_geozone_affiliation = params[:geozone_affiliation] || "all_resources"
    @affiliated_geozones = (params[:affiliated_geozones] || "").split(",").map(&:to_i)
    take_by_geozone_affiliations

    @categories = @projekts.map { |p| p.tags.category }.flatten.uniq.compact.sort
    @tag_cloud = tag_cloud
    take_only_by_tag_names

    @sdgs = (@projekts.map(&:sdg_goals).flatten.uniq.compact + SDG::Goal.where(code: @filtered_goals).to_a).uniq
    @sdg_targets = (@projekts.map(&:sdg_targets).flatten.uniq.compact + SDG::Target.where(code: @filtered_targets).to_a).uniq
    @filtered_goals = params[:sdg_goals].present? ? params[:sdg_goals].split(',').map{ |code| code.to_i } : nil
    @filtered_targets = params[:sdg_targets].present? ? params[:sdg_targets].split(',')[0] : nil
    take_by_sdgs

    @show_comments = Setting["extended_feature.projekts_overview_page_footer.show_in_#{@current_projekts_filter}"].present?

    if @show_comments
      set_variables_for_footer_comments
    end

    @projekts = @projekts.select { |p| p.visible_for?(current_user) }.sort_by(&:created_at).reverse
    @projekts = Kaminari.paginate_array(@projekts).page(params[:page]).per(25)

    if Setting.new_design_enabled?
      render :index_new
    else
      render :index
    end
  end

  def footer_comments
    set_variables_for_footer_comments
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
    image_url = projekt.image.present? ? url_for(projekt.image.variant(:popup)) : nil
    tags = projekt.tags.pluck(:name)

    sdg_goals = []
    projekt.sdg_goals.each do |goal|
      sdg_goals.push({
        code: goal.code,
        image: "sdg/goal_#{goal.code}.png"
      })
    end

    data = {
      projekt_id: projekt.id,
      projekt_title: projekt.title,
      image_url: image_url,
      tags: tags,
      sdg_goals: sdg_goals
    }.to_json

    respond_to do |format|
      format.json { render json: data }
    end
  end

  def map_html
    @projekt = Projekt.find(params[:id])
  end

  private

  def take_only_by_tag_names
    if params[:tags].present?
      @projekts = @projekts.tagged_with(params[:tags].split(","), all: true)
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

  def tag_cloud
    TagCloud.new(Projekt.all, params[:tags])
  end

  def raise_flag_feature_disabled
    raise FeatureFlags::FeatureDisabled, :projekts_overview unless Setting["extended_feature.projekts_overview_page_navigation.show_in_navigation"]
  end

  def set_variables_for_footer_comments
    @valid_orders = %w[most_voted newest oldest]
    @current_order = @valid_orders.include?(params[:order]) ? params[:order] : @valid_orders.first

    @commentable = Projekt.unscoped.find_by(special: true, special_name: "projekt_overview_page")
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
    set_comment_flags(@comment_tree.comments)
  end
end
