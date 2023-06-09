module ProjektPhaseActions
  extend ActiveSupport::Concern
  include Translatable

  included do
    before_action :set_projekt_phase
    helper_method :namespace_projekt_phase_path
  end

  def update
    if @projekt_phase.update(projekt_phase_params)
      redirect_to namespace_projekt_phase_path(action: params[:action_name] || "duration"),
        notice: t("admin.settings.index.map.flash.update")
    end
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
    @projekt_phase_settings = @projekt_phase.settings
  end

  private

    def projekt_phase_params
      filter_empty_registered_address_grouping_restrictions if params[:projekt_phase][:registered_address_grouping_restrictions]

      params.require(:projekt_phase).permit(
        translation_params(ProjektPhase),
        :active, :start_date, :end_date,
        :verification_restricted, :age_restriction_id,
        :geozone_restricted, :registered_address_grouping_restriction,
        geozone_restriction_ids: [], registered_address_street_ids: [],
        individual_group_value_ids: [],
        registered_address_grouping_restrictions: registered_address_grouping_restrictions_params_to_permit)
    end

    def set_projekt_phase
      @projekt_phase = ProjektPhase.find(params[:id])
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
end
