class Admin::ProjektsController < Admin::BaseController
  include MapLocationAttributes
  include Translatable
  include ImageAttributes

  before_action :find_projekt, only: [:update, :liveupdate, :destroy, :quick_update]
  before_action :load_geozones, only: [:new, :create, :edit, :update]
  before_action :process_tags, only: [:update]

  def index
    @projekts = Projekt.top_level
    @projekt = Projekt.new

    @projekts_settings = Setting.all.group_by(&:type)['projekts']
    skip_user_verification_setting = Setting.find_by(key: 'feature.user.skip_verification')
    @projekts_settings.push(skip_user_verification_setting)

    @map_configuration_settings = Setting.all.group_by(&:type)['map']
    @geozones = Geozone.all.order(Arel.sql("LOWER(name)"))
  end

  def show
    redirect_to edit_admin_projekt_path
  end

  def edit
    @projekt = Projekt.find(params[:id])

    if @projekt.map_location.nil?
      @projekt.send(:create_map_location)
      @projekt.reload
    end

    @projekt.build_comment_phase if @projekt.comment_phase.blank?
    @projekt.comment_phase.geozone_restrictions.build

    @projekt.build_debate_phase if @projekt.debate_phase.blank?
    @projekt.debate_phase.geozone_restrictions.build

    @projekt.build_proposal_phase if @projekt.proposal_phase.blank?
    @projekt.proposal_phase.geozone_restrictions.build

    @projekt.build_budget_phase if @projekt.budget_phase.blank?
    @projekt.budget_phase.geozone_restrictions.build

    @projekt.build_voting_phase if @projekt.voting_phase.blank?
    @projekt.voting_phase.geozone_restrictions.build

    @projekt.build_event_phase if @projekt.event_phase.blank?
    @projekt.event_phase.geozone_restrictions.build

    @projekt.build_map_location if @projekt.map_location.blank?

    all_settings = ProjektSetting.where(projekt: @projekt).group_by(&:type)
    all_projekt_features = all_settings["projekt_feature"].group_by(&:projekt_feature_type)
    @projekt_features_main = all_projekt_features['main']

    @projekt_features_phase_projekt_notification_info = ProjektSetting.find_by(projekt: @projekt, key: 'projekt_feature.phase.projekt_notification_info')
    @projekt_features_phase_newsfeed_info = ProjektSetting.find_by(projekt: @projekt, key: 'projekt_feature.phase.newsfeed_info')
    @projekt_features_phase_event_info = ProjektSetting.find_by(projekt: @projekt, key: 'projekt_feature.phase.event_info')

    @projekt_features_general = all_projekt_features['general']
    @projekt_features_sidebar = all_projekt_features['sidebar']
    @projekt_features_footer = all_projekt_features['footer']
    @projekt_features_debates = all_projekt_features['debates']
    @projekt_features_proposals = all_projekt_features['proposals']
    @projekt_options_proposals = all_projekt_features['proposal_options']
    @projekt_features_polls = all_projekt_features['polls']
    @projekt_features_budgets = all_projekt_features['budgets']
    @projekt_features_milestones = all_projekt_features['milestones']

    @projekt_newsfeed_settings = all_settings["projekt_newsfeed"]

    @projekt_notification = ProjektNotification.new
    @projekt_notifications = ProjektNotification.where(projekt: @projekt).order(created_at: :desc)

    @projekt_event = ProjektEvent.new
    @projekt_events = ProjektEvent.where(projekt: @projekt).order(created_at: :desc)

    @default_footer_tab_setting = ProjektSetting.find_by(projekt: @projekt, key: 'projekt_custom_feature.default_footer_tab')
  end

  def quick_update
    @projekt.update_attributes(projekt_params)
    Projekt.ensure_order_integrity

    redirect_back(fallback_location: admin_projekts_path)
  end

  def update
    if @projekt.update_attributes(projekt_params)
      redirect_to edit_admin_projekt_path(params[:id]) + params[:tab].to_s, notice: t("admin.settings.index.map.flash.update")
    else
      redirect_to edit_admin_projekt_path(params[:id]) + params[:tab].to_s, alert: @projekt.errors.messages.values.flatten.join('; ')
    end
  end

  def liveupdate
    @projekt.update_attributes(projekt_params)
  end

  def update_map
    map_location = MapLocation.find_by(projekt: params[:projekt_id])
    map_location.update(map_location_params)

    redirect_to edit_admin_projekt_path(params[:projekt_id]) + '#tab-projekt-map', notice: t("admin.settings.index.map.flash.update")
  end

  def create
    @projekts = Projekt.top_level.page(params[:page])
    @projekt = Projekt.new(projekt_params.merge(color: "#073E8E"))
    @projekt.order_number = 0

    if @projekt.save
      Projekt.ensure_order_integrity
      redirect_to admin_projekts_path
    else
      render :index
    end
  end

  def destroy
    @projekt.children.each do |child|
      child.update(parent: nil)
    end
    @projekt.debates.unscope(where: :hidden_at).each do |debate|
      debate.update(projekt_id: nil)
    end
    @projekt.proposals.unscope(where: :hidden_at).each do |proposal|
      proposal.update(projekt_id: nil)
    end
    @projekt.polls.unscope(where: :hidden_at).each do |poll|
      poll.update(projekt_id: nil)
    end
    @projekt.destroy!
    redirect_to admin_projekts_path
  end

  def order_up
    @projekt = Projekt.find(params[:id])
    @projekt.order_up
    redirect_to admin_projekts_path
  end

  def order_down
    @projekt = Projekt.find(params[:id])
    @projekt.order_down
    redirect_to admin_projekts_path
  end

  private

  def projekt_params
    attributes = [
      :name, :parent_id, :total_duration_start, :total_duration_end, :color, :icon, :geozone_affiliated, :tag_list, :related_sdg_list, geozone_affiliation_ids: [], sdg_goal_ids: [],
      comment_phase_attributes: [:id, :start_date, :end_date, :geozone_restricted, :active, :info_active, geozone_restriction_ids: [] ],
      debate_phase_attributes: [:id, :start_date, :end_date, :geozone_restricted, :active, :info_active, geozone_restriction_ids: [] ],
      proposal_phase_attributes: [:id, :start_date, :end_date, :geozone_restricted, :active, :info_active, geozone_restriction_ids: [] ],
      budget_phase_attributes: [:id, :start_date, :end_date, :geozone_restricted, :active, :info_active, geozone_restriction_ids: [] ],
      voting_phase_attributes: [:id, :start_date, :end_date, :geozone_restricted, :active, :info_active, geozone_restriction_ids: [] ],
      legislation_process_phase_attributes: [:id, :start_date, :end_date, :geozone_restricted, :active, :info_active, geozone_restriction_ids: [] ],
      milestone_phase_attributes: [:id, :start_date, :end_date, :active, :info_active],
      question_phase_attributes: [:id, :start_date, :end_date, :active, :info_active],
      event_phase_attributes: [:id, :start_date, :end_date],
      map_location_attributes: map_location_attributes,
      image_attributes: image_attributes,
      projekt_notifications: [:title, :body],
      project_events: [:id, :title, :location, :datetime, :weblink],
    ]
    params.require(:projekt).permit(attributes, translation_params(Projekt))
  end

  def process_tags
    params[:projekt][:tag_list] = (params[:projekt][:tag_list_predefined] || "")
    params[:projekt].delete(:tag_list_predefined)
  end

  def map_location_params
    if params[:map_location]
      params.require(:map_location).permit(map_location_attributes)
    else
      params.permit(map_location_attributes)
    end
  end

  def find_projekt
    @projekt = Projekt.find(params[:id])
  end

  def load_geozones
    @geozones = Geozone.all.order(:name)
  end
end
