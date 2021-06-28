class Admin::ProjektSettingsController < Admin::BaseController
  def update
    @projekt = Projekt.find(params[:projekt_id])
    @projekt_setting = ProjektSetting.find_by(id: params[:id], projekt: @projekt)
    @projekt_setting.update!(projekt_settings_params)
    redirect_to request_referer, notice: t("admin.settings.flash.updated")
  end

  def update_default_projekt_footer_tab
    default_tab_setting = ProjektSetting.find_by(id: params[:id])
    default_tab_setting.update(projekt_settings_params)

    redirect_to request_referer, notice: t("admin.settings.flash.updated")
  end

  private

  def projekt_settings_params
    params.require(:projekt_setting).permit(:value)
  end

  def request_referer
    return request.referer + params[:projekt_setting][:tab] if params[:projekt_setting][:tab]

    request.referer
  end
end
