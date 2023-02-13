module ProjektPhaseActions
  extend ActiveSupport::Concern
  include Translatable

  included do
    before_action :set_projekt, only: [:edit, :update, :toggle_active_status]
    before_action :set_projekt_phase, only: [:edit, :update, :toggle_active_status]

    helper_method :namespace_projekt_phase_path, :edit_namespace_projekt_path
  end

  def edit
  end

  def update
    if @projekt_phase.update(projekt_phase_params)
      redirect_to edit_namespace_projekt_path(@projekt),
        notice: t("admin.settings.index.map.flash.update")
    end
  end

  def toggle_active_status
    status_value = params[:projekt][:phase_attributes][:active]
    @projekt_phase.update!(active: status_value)
  end

  private

    def projekt_phase_params
      params.require(:projekt_phase).permit(
        translation_params(ProjektPhase),
        :active, :start_date, :end_date,
        :verification_restricted, :age_restriction_id,
        :geozone_restricted, geozone_restriction_ids: [], city_street_ids: [])
    end

    def set_projekt
      @projekt = Projekt.find(params[:projekt_id])
    end

    def set_projekt_phase
      @projekt_phase = ProjektPhase.find(params[:id])
    end
end
