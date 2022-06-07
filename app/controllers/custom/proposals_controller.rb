require_dependency Rails.root.join("app", "controllers", "proposals_controller").to_s

class ProposalsController
  include ProposalsHelper
  include ProjektControllerHelper
  include Takeable

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

    @top_level_active_projekts = Projekt.top_level_sidebar_current('proposals')
    @top_level_archived_projekts = Projekt.top_level_sidebar_expired('proposals')

    discard_draft
    discard_archived
    load_retired
    load_selected
    load_featured
    remove_archived_from_order_links

    @scoped_projekt_ids = (@top_level_active_projekts + @top_level_archived_projekts)
      .map{ |p| p.all_children_projekts.unshift(p) }
      .flatten.select do |projekt|
        ProjektSetting.find_by( projekt: projekt, key: 'projekt_feature.proposals.show_in_sidebar_filter').value.present?
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

    @proposals_coordinates = all_proposal_map_locations(@resources)
    @proposals = @resources.page(params[:page]).send("sort_by_#{@current_order}")
    # @selected_tags = all_selected_tags
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

  def create
    @proposal = Proposal.new(proposal_params.merge(author: current_user))

    if params[:save_draft].present? && @proposal.save
      redirect_to user_path(@proposal.author, filter: 'proposals'), notice: I18n.t("flash.actions.create.proposal")

    elsif @proposal.save
      @proposal.publish

      if @proposal.proposal_phase.info_active?
        redirect_to page_path(
          @proposal.projekt.page.slug,
          anchor: 'filter-subnav',
          selected_phase_id: @proposal.proposal_phase.id,
          order: 'created_at'), notice: t("proposals.notice.published")
      else
        redirect_to proposals_path(order: 'created_at'), notice: t("proposals.notice.published")
      end

    else
      render :new

    end
  end

  def publish
    @proposal.publish

    if @proposal.proposal_phase.info_active?
      redirect_to page_path(
        @proposal.projekt.page.slug,
        anchor: 'filter-subnav',
        selected_phase_id: @proposal.proposal_phase.id,
        order: 'created_at'), notice: t("proposals.notice.published")
    else
      redirect_to proposals_path(order: 'created_at'), notice: t("proposals.notice.published")
    end
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

    def proposal_params
      attributes = [:video_url, :responsible_name, :tag_list, :on_behalf_of,
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
