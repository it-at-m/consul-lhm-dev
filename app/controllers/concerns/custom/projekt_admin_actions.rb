module ProjektAdminActions
  extend ActiveSupport::Concern
  include MapLocationAttributes
  include Translatable
  include ImageAttributes

  included do
    alias_method :namespace_mappable_path, :namespace_projekt_path

    helper_method :namespace_projekt_path, :namespace_mappable_path
  end

  def edit
    @projekt = Projekt.find(params[:id])
    @namespace = params[:controller].split("/").first.to_sym

    if @projekt.map_location.nil?
      @projekt.send(:create_map_location)
      @projekt.reload
    end

    @individual_groups = IndividualGroup.hard.visible

    @projekt.build_map_location if @projekt.map_location.blank?

    all_settings = ProjektSetting.where(projekt: @projekt).group_by(&:type)
    all_projekt_features = all_settings["projekt_feature"].group_by(&:projekt_feature_type)
    @projekt_features_main = all_projekt_features["main"]
    @projekt_features_general = all_projekt_features["general"]
    @projekt_features_sidebar = all_projekt_features["sidebar"]

    @projekt_managers = ProjektManager.all

    @default_footer_tab_setting = ProjektSetting.find_by(
      projekt: @projekt,
      key: "projekt_custom_feature.default_footer_tab"
    )
  end

  def update
    if should_authorize_projekt_manager?
      authorize!(:update, @projekt)
    end

    if @projekt.update_attributes(projekt_params)
      redirect_to redirect_path(params[:id], params[:tab].to_s),
        notice: t("admin.settings.index.map.flash.update")
    else
      redirect_to redirect_path(params[:id], params[:tab].to_s),
        alert: @projekt.errors.messages.values.flatten.join("; ")
    end
  end

  def update_map
    map_location = MapLocation.find_by(projekt: params[:projekt_id])

    if should_authorize_projekt_manager?
      authorize!(:update_map, map_location)
    end

    map_location.update!(map_location_params)

    redirect_to redirect_path(params[:projekt_id], "#tab-projekt-map"),
      notice: t("admin.settings.index.map.flash.update")
  end

  def update_standard_phase
    @projekt = Projekt.find(params[:id]).reload
    @default_footer_tab_setting = ProjektSetting.find_by(
      projekt: @projekt,
      key: "projekt_custom_feature.default_footer_tab"
    ).reload

    if should_authorize_projekt_manager?
      authorize!(:update_standard_phase, @default_footer_tab_setting)
    end

    if @default_footer_tab_setting.present?
      @default_footer_tab_setting.update!(value: params[:default_footer_tab][:id])
    end

    respond_to do |format|
      format.js
    end
  end

  private

    def projekt_params
      attributes = [
        :name, :parent_id, :total_duration_start, :total_duration_end, :color, :icon,
        :show_start_date_in_frontend, :show_end_date_in_frontend,
        :geozone_affiliated, :tag_list, :related_sdg_list, geozone_affiliation_ids: [], sdg_goal_ids: [],
        individual_group_value_ids: [],
        map_location_attributes: map_location_attributes,
        image_attributes: image_attributes,
        projekt_notifications: [:title, :body],
        project_events: [:id, :title, :location, :datetime, :weblink],
        projekt_manager_ids: []
      ]
      params.require(:projekt).permit(attributes, translation_params(Projekt))
    end

    def process_tags
      params[:projekt][:tag_list] = (params[:projekt][:tag_list_predefined] || @projekt.tag_list.join(','))
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

    def redirect_path(projekt_id, tab)
      if params[:namespace] == "projekt_management"
        edit_projekt_management_projekt_path(projekt_id) + tab
      else
        edit_admin_projekt_path(projekt_id) + tab
      end
    end

    def should_authorize_projekt_manager?
      current_user&.projekt_manager? && !current_user&.administrator?
    end

    # path helpers

    def namespace_projekt_path(action: "update", anchor: nil)
      url_for(controller: params[:controller], action: action, anchor: anchor, only_path: true)
    end
end
