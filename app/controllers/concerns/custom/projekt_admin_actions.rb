module ProjektAdminActions
  extend ActiveSupport::Concern
  include MapLocationAttributes
  include Translatable
  include ImageAttributes

  included do
    alias_method :namespace_mappable_path, :namespace_projekt_path
    helper_method :namespace_projekt_path, :namespace_mappable_path

    before_action :find_projekt, except: %i[index create]
    before_action :process_tags, only: [:update]
  end

  def edit
    @namespace = params[:controller].split("/").first.to_sym

    authorize!(:edit, @projekt) unless current_user.administrator?

    @individual_groups = IndividualGroup.hard.visible

    all_settings = ProjektSetting.where(projekt: @projekt).group_by(&:type)
    all_projekt_features = all_settings["projekt_feature"].group_by(&:projekt_feature_type)
    @projekt_features_main = all_projekt_features["main"]
    @projekt_features_general = all_projekt_features["general"]
    @projekt_features_sidebar = all_projekt_features["sidebar"]

    @default_footer_tab_setting = ProjektSetting.find_by(
      projekt: @projekt,
      key: "projekt_custom_feature.default_footer_tab"
    )

    ProjektManager.all.map { |pm| pm.projekt_manager_assignments.find_or_create_by!(projekt: @projekt) }
    @projekt_manager_assignments = @projekt.projekt_manager_assignments

    if @projekt.map_location.nil?
      @projekt.send(:create_map_location)
      @projekt.reload
    end

    render "custom/admin/projekts/edit"
  end

  def update
    authorize!(:update, @projekt) unless current_user.administrator?

    if @projekt.update_attributes(projekt_params)
      redirect_to namespace_projekt_path(action: "edit", anchor: params[:tab]),
        notice: t("custom.admin.projekts.edit.flash.update_notice")
    else
      redirect_to namespace_projekt_path(action: "edit"),
        alert: @projekt.errors.messages.values.flatten.join("; ")
    end
  end

  def update_map
    map_location = MapLocation.find_by(projekt_id: @projekt.id)

    authorize!(:update_map, map_location) unless current_user.administrator?

    map_location.update!(map_location_params)

    redirect_to namespace_projekt_path(action: "edit", anchor: "tab-projekt-map"),
      notice: t("admin.settings.index.map.flash.update")
  end

  def update_standard_phase
    @projekt.reload
    @default_footer_tab_setting = ProjektSetting.find_by(
      projekt: @projekt,
      key: "projekt_custom_feature.default_footer_tab"
    ).reload

    authorize!(:update_standard_phase, @default_footer_tab_setting) unless current_user.administrator?

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
        projekt_manager_assignments_attributes: [:id, :projekt_manager_id, :projekt_id, permissions: []]
      ]
      params.require(:projekt).permit(attributes, translation_params(Projekt))
    end

    def process_tags
      params[:projekt][:tag_list] = (params[:projekt][:tag_list_predefined] || @projekt.tag_list.join(","))
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

    # path helpers

    def namespace_projekt_path(action: "update", anchor: nil)
      url_for(controller: params[:controller], action: action, anchor: anchor, only_path: true)
    end
end
