require_dependency Rails.root.join("app", "controllers", "admin", 'site_customization', "pages_controller").to_s

class Admin::SiteCustomization::PagesController < Admin::SiteCustomization::BaseController
  include ImageAttributes

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
end
