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
    @projekt_phase = ProjektPhase.new(projekt_phase_params.merge(active: true))

    authorize!(:create, @projekt_phase) unless current_user.administrator?

    @projekt_phase.save!

    redirect_to polymorphic_path([@namespace, @projekt], action: :edit, anchor: "tab-projekt-phases"),
      notice: t("custom.admin.projekt_phases.notice.created")
  end

  def update
    authorize!(:create, @projekt_phase) unless current_user.administrator?

    if @projekt_phase.update(projekt_phase_params)
      redirect_to namespace_projekt_phase_path(action: params[:action_name] || "duration"),
        notice: t("custom.admin.projekt_phases.notice.updated")
    end
  end

  def destroy
    authorize!(:destroy, @projekt_phase) unless current_user.administrator?

    if @projekt_phase.safe_to_destroy?
      @projekt_phase.destroy!
      redirect_to polymorphic_path([@namespace, @projekt], action: :edit, anchor: "tab-projekt-phases"),
        notice: t("custom.admin.projekt_phases.notice.destroyed")

    else
      redirect_to polymorphic_path([@namespace, @projekt], action: :edit, anchor: "tab-projekt-phases"),
        notice: t("custom.admin.projekt_phases.notice.not_destroyed")

    end
  end

  def order_phases
    @projekt = Projekt.find(params[:projekt_id])
    authorize!(:order_phases, @projekt) unless current_user.administrator?

    @projekt.projekt_phases.order_phases(params[:ordered_list])
    head :ok
  end

  def toggle_active_status
    authorize!(:toggle_active_status, @projekt_phase) unless current_user.administrator?

    status_value = params[:projekt][:phase_attributes][:active]
    @projekt_phase.update!(active: status_value)
  end

  def duration
    authorize!(:duration, @projekt_phase) unless current_user.administrator?

    render "custom/admin/projekt_phases/duration"
  end

  def naming
    authorize!(:naming, @projekt_phase) unless current_user.administrator?

    render "custom/admin/projekt_phases/naming"
  end

  def restrictions
    authorize!(:restrictions, @projekt_phase) unless current_user.administrator?

    @registered_address_groupings = RegisteredAddress::Grouping.all
    @individual_groups = IndividualGroup.visible

    render "custom/admin/projekt_phases/restrictions"
  end

  def settings
    authorize!(:settings, @projekt_phase) unless current_user.administrator?

    all_settings = @projekt_phase.settings.group_by(&:kind)
    @projekt_phase_features = all_settings["feature"]&.group_by(&:band) || []
    @projekt_phase_options = all_settings["option"]&.group_by(&:band) || []

    render "custom/admin/projekt_phases/settings"
  end

  def projekt_labels
    authorize!(:projekt_labels, @projekt_phase) unless current_user.administrator?

    @projekt_labels = @projekt_phase.projekt_labels

    render "custom/admin/projekt_phases/projekt_labels"
  end

  def sentiments
    authorize!(:sentiments, @projekt_phase) unless current_user.administrator?
    @sentiments = @projekt_phase.sentiments

    render "custom/admin/projekt_phases/sentiments"
  end

  def map
    authorize!(:map, @projekt_phase) unless current_user.administrator?

    @projekt_phase.create_map_location unless @projekt_phase.map_location.present?
    @map_location = @projekt_phase.map_location

    render "custom/admin/projekt_phases/map"
  end

  def update_map
    map_location = MapLocation.find_by(projekt_phase_id: params[:id])

    authorize!(:update_map, map_location) unless current_user.administrator?

    map_location.update!(map_location_params)

    redirect_to namespace_projekt_phase_path(action: "map"),
      notice: t("admin.settings.index.map.flash.update")
  end

  def projekt_questions
    authorize!(:projekt_questions, @projekt_phase) unless current_user.administrator?
    @projekt_questions = @projekt_phase.questions

    render "custom/admin/projekt_phases/projekt_questions"
  end

  def projekt_livestreams
    authorize!(:projekt_livestreams, @projekt_phase) unless current_user.administrator?
    @projekt_livestream = ProjektLivestream.new
    @projekt_livestreams = @projekt_phase.projekt_livestreams

    render "custom/admin/projekt_phases/projekt_livestreams"
  end

  def projekt_events
    authorize!(:projekt_events, @projekt_phase) unless current_user.administrator?
    @projekt_event = ProjektEvent.new
    @projekt_events = @projekt_phase.projekt_events

    render "custom/admin/projekt_phases/projekt_events"
  end

  def milestones
    authorize!(:milestones, @projekt_phase) unless current_user.administrator?
    render "custom/admin/projekt_phases/milestones"
  end

  def projekt_notifications
    authorize!(:projekt_notifications, @projekt_phase) unless current_user.administrator?
    @projekt_notification = ProjektNotification.new
    @projekt_notifications = @projekt_phase.projekt_notifications

    render "custom/admin/projekt_phases/projekt_notifications"
  end

  def projekt_arguments
    authorize!(:projekt_arguments, @projekt_phase) unless current_user.administrator?
    @projekt_argument = ProjektArgument.new
    @projekt_arguments_pro = @projekt_phase.projekt_arguments.pro
    @projekt_arguments_cons = @projekt_phase.projekt_arguments.cons

    render "custom/admin/projekt_phases/projekt_arguments"
  end

  def formular
    @formular = @projekt_phase.formular
    @formular_fields_primary = @formular.formular_fields.primary.each(&:set_custom_attributes)
    @formular_fields_follow_up = @formular.formular_fields.follow_up.each(&:set_custom_attributes)
    authorize!(:formular, @projekt_phase) unless current_user.administrator?
    render "custom/admin/projekt_phases/formular"
  end

  def formular_answers
    authorize!(:formular, @projekt_phase) unless current_user.administrator?

    @formular = @projekt_phase.formular
    @formular_fields = @formular.formular_fields
    @formular_answers = @formular.formular_answers
    @formular_follow_up_letters = @formular.formular_follow_up_letters
    @image_flag = @formular_answers.any? { |fa| fa.formular_answer_images.present? }

    respond_to do |format|
      format.html { render "custom/admin/projekt_phases/formular_answers" }
      format.csv do
        send_data CsvServices::FormularAnswersExporter.call(@formular),
          filename: "formular_answers-#{@formular.id}-#{Time.zone.today}.csv"
      end
    end
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
