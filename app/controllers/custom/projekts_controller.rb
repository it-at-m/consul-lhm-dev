class ProjektsController < ApplicationController
  include CustomHelper
  include ProposalsHelper

  skip_authorization_check
  has_orders %w[index_order_underway index_order_all index_order_ongoing index_order_upcoming
                index_order_expired index_order_individual_list], only: :index

  before_action :raise_flag_feature_disabled, except: [:map_html]

  include ProjektControllerHelper

  def index
    @projekts = Projekt.regular.with_published_custom_page

    @resource_name = "projekt"
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

    valid_orders.push("index_order_drafts") if current_user&.administrator? || current_user&.projekt_manager?
    @active_projekts_orders = valid_orders.select { |order| @projekts.send(order).count > 0 }.presence || ["index_order_all"]
    @current_projekts_order = valid_orders.include?(params[:order]) ? params[:order] : @active_projekts_orders.first
    @special_projekt = Projekt.unscoped.find_by(special: true, special_name: "projekt_overview_page")
    @projekts = @projekts.send(@current_projekts_order)
    @map_coordinates = all_projekts_map_locations(@projekts.pluck(:id))

    @show_comments = Setting["extended_feature.projekts_overview_page_footer.show_in_#{@current_order}"]
    @valid_comments_orders = %w[most_voted newest oldest]
    @current_comments_order = @valid_comments_orders.include?(params[:order]) ? params[:order] : @valid_comments_orders.first
    @commentable = @special_projekt
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_comments_order)
    set_comment_flags(@comment_tree.comments)

    if @projekts.is_a?(Array)
      @projekts = Kaminari.paginate_array(@projekts).page(params[:page]).per(25)
    else
      @projekts = @projekts.page(params[:page]).per(25)
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
end
