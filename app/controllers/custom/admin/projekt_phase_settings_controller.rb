class Admin::ProjektPhaseSettingsController < Admin::BaseController
  def update
    @projekt_phase_setting = ProjektPhaseSetting.find_by(id: params[:id])
      # above line is a workaround to avoid editing FeaturedSettingsComponent

    authorize!(:update, @projekt_phase_setting) unless current_user.administrator?

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
