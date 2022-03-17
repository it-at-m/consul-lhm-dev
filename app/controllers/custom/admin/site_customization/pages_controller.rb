require_dependency Rails.root.join("app", "controllers", "admin", 'site_customization', "pages_controller").to_s

class Admin::SiteCustomization::PagesController < Admin::SiteCustomization::BaseController
  include ImageAttributes


  def update
    if @page.update(page_params)
      notice = t("admin.site_customization.pages.update.notice")
      redirect_to redirect_path, notice: notice
    else
      flash.now[:error] = t("admin.site_customization.pages.update.error")
      render :edit
    end
  end

  def destroy
    if @page.safe_to_destroy?
      @page.destroy!
      notice = t("admin.site_customization.pages.destroy.notice")
      redirect_to admin_site_customization_pages_path, notice: notice
    else
      notice = t("custom.admin.site_customization.pages.destroy.cannot_notice")
      redirect_to admin_site_customization_pages_path, alert: notice
    end
  end

  private

    def page_params
      attributes = [:slug, :more_info_flag, :print_content_flag, :status,
                    image_attributes: image_attributes]

      params.require(:site_customization_page).permit(*attributes,
        translation_params(SiteCustomization::Page)
      )
    end

    def resource
      SiteCustomization::Page.find(params[:id])
    end

    def redirect_path
      if @page.projekt.present?
        edit_admin_projekt_path(@page.projekt)
      else
        admin_site_customization_pages_path
      end
    end
end
