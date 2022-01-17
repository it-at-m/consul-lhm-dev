class Admin::ProjektSettingsController < Admin::BaseController
  def update
    @projekt_setting = ProjektSetting.find_by(id: params[:projekt_id]) #workaround to avoid editing FeaturedSettingsComponent
    @projekt_setting.update!(projekt_setting_params)

    respond_to do |format|
      format.html { redirect_to request_referer, notice: t("admin.settings.flash.updated") }
      format.js
    end
  end

  def update_default_projekt_footer_tab
    default_tab_setting = ProjektSetting.find_by(id: params[:id])
    default_tab_setting.update(projekt_setting_params)

    redirect_to request_referer, notice: t("admin.settings.flash.updated")
  end

  private

  def projekt_setting_params
    params.require(:projekt_setting).permit(:value)
  end

  def request_referer
    return request.referer + params[:projekt_setting][:tab] if params[:projekt_setting][:tab]

    request.referer
  end
end
