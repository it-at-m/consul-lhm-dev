class Admin::ProjektPhaseSettingsController < Admin::BaseController
  def update
    @projekt_phase_setting = ProjektPhaseSetting.find_by(id: params[:id])
      # above line is a workaround to avoid editing FeaturedSettingsComponent

    if should_authorize_projekt_manager?
      authorize! :update, @projekt_phase_setting
    end

    @projekt_phase_setting.update!(projekt_phase_setting_params)

    respond_to do |format|
      format.html { redirect_to request.referer, notice: t("admin.settings.flash.updated") }
      format.js
    end
  end

  private

    def projekt_phase_setting_params
      params.require(:projekt_phase_setting).permit(:value)
    end
end
