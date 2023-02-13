require_dependency Rails.root.join("app", "controllers", "debates_controller").to_s

class DebatesController < ApplicationController
  include ImageAttributes
  include ProjektControllerHelper
  include DocumentAttributes
  include Takeable
  include ProjektLabelAttributes

  before_action :load_categories, only: [:index, :create, :edit, :map, :summary]
  before_action :process_tags, only: [:create, :update]
  before_action :set_projekts_for_selector, only: [:new, :edit, :create, :update]

  def index_customization
    if params[:order].nil?
      @current_order = Setting["selectable_setting.debates.default_order"]
    end

    @resource_name = "debate"

    if params[:filter_projekt_ids]
      @selected_projekts_ids = params[:filter_projekt_ids].select { |id| Projekt.find_by(id: id).present? }
      selected_parent_projekt_id = get_highest_unique_parent_projekt_id(@selected_projekts_ids)
      @selected_parent_projekt = Projekt.find_by(id: selected_parent_projekt_id)
    end

    @geozones = Geozone.all
    @selected_geozone_affiliation = params[:geozone_affiliation] || "all_resources"
    @affiliated_geozones = (params[:affiliated_geozones] || "").split(",").map(&:to_i)
    @selected_geozone_restriction = params[:geozone_restriction] || "no_restriction"
    @restricted_geozones = (params[:restricted_geozones] || "").split(",").map(&:to_i)

    @featured_debates = Debate.featured

    @scoped_projekt_ids = Debate.scoped_projekt_ids_for_index

    @top_level_active_projekts = Projekt.top_level.current.where(id: @scoped_projekt_ids)
    @top_level_archived_projekts = Projekt.top_level.expired.where(id: @scoped_projekt_ids)

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

  def new
    redirect_to debates_path if Projekt.top_level.selectable_in_selector('debates', current_user).empty?

    @resource = resource_model.new
    set_geozone
    set_resource_instance
    @selected_projekt = Projekt.find(params[:projekt_id]) if params[:projekt_id]
  end

  def edit
    @selected_projekt = @debate.projekt
  end

  def create
    @debate = Debate.new(strong_params)
    @debate.author = current_user

    if @debate.save
      track_event
      NotificationServices::NewDebateNotifier.new(@debate.id).call

      if @debate.debate_phase.active?
        if @debate.projekt.overview_page?
          redirect_to projekts_path(
            anchor: 'filter-subnav',
            selected_phase_id: @debate.debate_phase.id,
            order: params[:order]
          ), notice: t("flash.actions.create.debate")
        else
          redirect_to page_path(
            @debate.projekt.page.slug,
            anchor: 'filter-subnav',
            selected_phase_id: @debate.debate_phase.id,
            order: params[:order]
          ), notice: t("flash.actions.create.debate")
        end
      else
        if @debate.projekt.overview_page?
          redirect_to projekts_path(
            anchor: 'filter-subnav',
            selected_phase_id: @debate.debate_phase.id,
            order: params[:order]
          ), notice: t("flash.actions.create.debate")
        else
          redirect_to proposals_path(
            resources_order: params[:order]
          ), notice: t("flash.actions.create.debate")
        end
      end
    else
      @selected_projekt = @debate.projekt
      render :new
    end
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
                  projekt_label_ids: [],
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
