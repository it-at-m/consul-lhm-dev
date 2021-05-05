require_dependency Rails.root.join("app", "controllers", "proposals_controller").to_s

class ProposalsController

  include ProposalsHelper

  before_action :authenticate_user!, except: [:index, :show, :map, :summary, :json_data]
  before_action :process_tags, only: [:create, :update]

  def index_customization
    discard_draft
    discard_archived
    load_retired
    load_selected
    load_featured
    remove_archived_from_order_links
    take_only_by_tag_names
    take_by_projekts
    @proposals_coordinates = all_proposal_map_locations
    @selected_tags = all_selected_tags
  end

  def new
    redirect_to proposals_path if proposal_limit_exceeded?(current_user)
    @resource = resource_model.new
    set_geozone
    set_resource_instance
    @projekts = Projekt.top_level
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
  end

  def unvote
    @follow = Follow.find_by(user: current_user, followable: @proposal)
    @follow.destroy if @follow
    @proposal.unvote_by(current_user)
    set_proposal_votes(@proposal)
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

    def proposal_params
      attributes = [:video_url, :responsible_name, :tag_list,
                    :terms_of_service, :geozone_id, :skip_map, :projekt_id,
                    image_attributes: image_attributes,
                    documents_attributes: [:id, :title, :attachment, :cached_attachment,
                                           :user_id, :_destroy],
                    map_location_attributes: [:latitude, :longitude, :zoom]]
      translations_attributes = translation_params(Proposal, except: :retired_explanation)
      params.require(:proposal).permit(attributes, translations_attributes)
    end

    def proposal_limit_exceeded?(user)
      user.proposals.where(retired_at: nil).count >= Setting['extended_option.max_active_proposals_per_user'].to_i
    end
end
