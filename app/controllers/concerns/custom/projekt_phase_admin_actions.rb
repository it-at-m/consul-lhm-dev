module ProjektPhaseAdminActions
  extend ActiveSupport::Concern
  include Translatable
  include MapLocationAttributes

  included do
    alias_method :namespace_mappable_path, :namespace_projekt_phase_path

    before_action :set_projekt_phase, :authorize_nav_bar_action, except: [:create, :order_phases]
    before_action :set_namespace

    helper_method :namespace_projekt_phase_path, :namespace_mappable_path
  end

  def create
    @projekt = Projekt.find(params[:projekt_id])
    ProjektPhase.create!(projekt_phase_params.merge(active: true))

    redirect_to edit_admin_projekt_path(@projekt.id, anchor: "tab-projekt-phases"),
      notice: t("custom.admin.projekt_phases.notice.created")
  end

  def update
    if @projekt_phase.update(projekt_phase_params)
      redirect_to namespace_projekt_phase_path(action: params[:action_name] || "duration"),
        notice: t("custom.admin.projekt_phases.notice.updated")
    end
  end

  def destroy
    if @projekt_phase.safe_to_destroy?
      @projekt_phase.destroy!

      redirect_to edit_admin_projekt_path(@projekt_phase.projekt_id, anchor: "tab-projekt-phases"),
        notice: t("custom.admin.projekt_phases.notice.destroyed")

    else
      redirect_to edit_admin_projekt_path(@projekt_phase.projekt_id, anchor: "tab-projekt-phases"),
        notice: t("custom.admin.projekt_phases.notice.not_destroyed")

    end
  end

  def order_phases
    @projekt = Projekt.find(params[:projekt_id])
    @projekt.projekt_phases.order_phases(params[:ordered_list])
    head :ok
  end

  def toggle_active_status
    status_value = params[:projekt][:phase_attributes][:active]
    @projekt_phase.update!(active: status_value)
  end

  def duration; end

  def naming; end

  def restrictions
    @registered_address_groupings = RegisteredAddress::Grouping.all
    @individual_groups = IndividualGroup.visible
  end

  def settings
    all_settings = @projekt_phase.settings.group_by(&:kind)
    @projekt_phase_features = all_settings["feature"]&.group_by(&:band) || []
    @projekt_phase_options = all_settings["option"]&.group_by(&:band) || []
  end

  def map
    @projekt_phase.create_map_location unless @projekt_phase.map_location.present?
    @map_location = @projekt_phase.map_location
  end

  def update_map
    map_location = MapLocation.find_by(projekt_phase_id: params[:id])

    if should_authorize_projekt_manager?
      authorize!(:update_map, map_location)
    end

    map_location.update!(map_location_params)

    redirect_to namespace_projekt_phase_path(action: "map"),
      notice: t("admin.settings.index.map.flash.update")
  end

  def projekt_labels
    @projekt_labels = @projekt_phase.projekt_labels
  end

  def sentiments
    @sentiments = @projekt_phase.sentiments
  end

  def projekt_questions
    @projekt_questions = @projekt_phase.questions
  end

  def projekt_livestreams
    @projekt_livestream = ProjektLivestream.new
    @projekt_livestreams = @projekt_phase.projekt_livestreams
  end

  def projekt_events
    @projekt_event = ProjektEvent.new
    @projekt_events = @projekt_phase.projekt_events
  end

  def milestones
  end

  def projekt_notifications
    @projekt_notification = ProjektNotification.new
    @projekt_notifications = @projekt_phase.projekt_notifications
  end

  def projekt_arguments
    @projekt_argument = ProjektArgument.new
    @projekt_arguments_pro = @projekt_phase.projekt_arguments.pro
    @projekt_arguments_cons = @projekt_phase.projekt_arguments.cons
  end

  private

    def projekt_phase_params
      if params[:projekt_phase][:registered_address_grouping_restrictions]
        filter_empty_registered_address_grouping_restrictions
      end

      params.require(:projekt_phase).permit(
        translation_params(ProjektPhase),
        :projekt_id, :type,
        :active, :start_date, :end_date,
        :verification_restricted, :age_restriction_id,
        :geozone_restricted, :registered_address_grouping_restriction,
        geozone_restriction_ids: [], registered_address_street_ids: [],
        individual_group_value_ids: [],
        registered_address_grouping_restrictions: registered_address_grouping_restrictions_params_to_permit)
    end

    def map_location_params
      if params[:map_location]
        params.require(:map_location).permit(map_location_attributes)
      else
        params.permit(map_location_attributes)
      end
    end

    def set_projekt_phase
      @projekt_phase = ProjektPhase.find(params[:id])
      @projekt = @projekt_phase.projekt
    end

    def set_namespace
      @namespace = params[:controller].split("/").first.to_sym
    end

    def registered_address_grouping_restrictions_params_to_permit
      keys_hash = RegisteredAddress::Grouping.all
        .pluck(:key).each_with_object({}) do |key, hash|
          hash[key.to_sym] = []
        end
      keys_hash
    end

    def filter_empty_registered_address_grouping_restrictions
      grouping_restrictions = params[:projekt_phase][:registered_address_grouping_restrictions]
      return if grouping_restrictions.blank?

      filtered_grouping_restrictions = grouping_restrictions
        .reject { |_, v| v == [""] }
        .as_json
        .each { |_, v| v.reject!(&:blank?) }

      params[:projekt_phase][:registered_address_grouping_restrictions] = filtered_grouping_restrictions
    end

    def authorize_nav_bar_action
      possible_nab_bar_actions = @projekt_phase.projekt.projekt_phases.map(&:admin_nav_bar_items).flatten.uniq
      return unless action_name.in?(possible_nab_bar_actions)

      unless action_name.in?(@projekt_phase.admin_nav_bar_items)
        redirect_to namespace_projekt_phase_path(action: @projekt_phase.admin_nav_bar_items.first)
      end
    end

    # path helpers

    def namespace_projekt_phase_path(action: "update")
      url_for(controller: params[:controller], action: action, only_path: true)
    end
end
