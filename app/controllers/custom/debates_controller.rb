require_dependency Rails.root.join("app", "controllers", "debates_controller").to_s

class DebatesController < ApplicationController
  include ImageAttributes
  include ProjektControllerHelper
  include DocumentAttributes
  include Takeable

  before_action :load_categories, only: [:index, :create, :edit, :map, :summary]
  before_action :process_tags, only: [:create, :update]
  before_action :set_projekts_for_selector, only: [:new, :edit, :create, :update]

  def index_customization
    if Setting['projekts.set_default_sorting_to_newest'].present? &&
        @valid_orders.include?('created_at')
      @current_order = 'created_at'
    end

    @geozones = Geozone.all
    @selected_geozone_affiliation = params[:geozone_affiliation] || 'all_resources'
    @affiliated_geozones = (params[:affiliated_geozones] || '').split(',').map(&:to_i)
    @selected_geozone_restriction = params[:geozone_restriction] || 'no_restriction'
    @restricted_geozones = (params[:restricted_geozones] || '').split(',').map(&:to_i)

    @featured_debates = Debate.featured

    @top_level_active_projekts = Projekt.top_level_sidebar_current('debates')
    @top_level_archived_projekts = Projekt.top_level_sidebar_expired('debates')

    @scoped_projekt_ids = (@top_level_active_projekts + @top_level_archived_projekts)
      .map{ |p| p.all_children_projekts.unshift(p) }
      .flatten.select do |projekt|
        ProjektSetting.find_by( projekt: projekt, key: 'projekt_feature.debates.show_in_sidebar_filter').value.present?
      end
      .pluck(:id)

    unless params[:search].present?
      take_by_my_posts
      take_by_tag_names
      take_by_sdgs
      take_by_geozone_affiliations
      take_by_geozone_restrictions
      take_by_projekts(@scoped_projekt_ids)
    end

    @debates = @resources.page(params[:page]).send("sort_by_#{@current_order}")
  end

  def show
    super

    @projekt = @debate.projekt

    @related_contents = Kaminari.paginate_array(@debate.relationed_contents).page(params[:page]).per(5)
    redirect_to debate_path(@debate), status: :moved_permanently if request.path != debate_path(@debate)

    @geozones = Geozone.all

    @selected_geozone_affiliation = params[:geozone_affiliation] || 'all_resources'
    @affiliated_geozones = (params[:affiliated_geozones] || '').split(',').map(&:to_i)

    @selected_geozone_restriction = params[:geozone_restriction] || 'no_restriction'
    @restricted_geozones = (params[:restricted_geozones] || '').split(',').map(&:to_i)
  end

  def flag
    Flag.flag(current_user, @debate)
    redirect_to @debate
  end

  def unflag
    Flag.unflag(current_user, @debate)
    redirect_to @debate
  end

  private

  def debate_params
    attributes = [:tag_list, :terms_of_service, :projekt_id, :related_sdg_list, :on_behalf_of,
                  image_attributes: image_attributes,
                  documents_attributes: document_attributes]
    params.require(:debate).permit(attributes, translation_params(Debate))
  end

  def process_tags
    if params[:debate][:tags]
      params[:tags] = params[:debate][:tags].split(',')
      params[:debate].delete(:tags)
    end
    params[:debate][:tag_list_custom]&.split(",")&.each do |t|
      next if t.strip.blank?
      Tag.find_or_create_by name: t.strip
    end
    params[:debate][:tag_list] ||= ""
    params[:debate][:tag_list] += ((params[:debate][:tag_list_predefined] || "").split(",") + (params[:debate][:tag_list_custom] || "").split(",")).join(",")
    params[:debate].delete(:tag_list_predefined)
    params[:debate].delete(:tag_list_custom)
  end
end
