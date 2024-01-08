class ProjektManagement::SiteCustomization::PagesController < ProjektManagement::BaseController
  include Translatable
  include ImageAttributes
  load_and_authorize_resource :page, class: "SiteCustomization::Page"

  def update
    if @page.update(page_params)
      notice = t("admin.site_customization.pages.update.notice")
      redirect_to redirect_path, notice: notice
    else
      alert = t("admin.site_customization.pages.update.error")
      redirect_to redirect_path, alert: alert
    end
  end

  private

    def redirect_path
      if @page.projekt.present? && @page.published? && params[:origin] == "public_page"
        page_path(@page.slug)
      elsif @page.projekt.present?
        polymorphic_path([@namespace, @page.projekt], action: :edit, anchor: "tab-projekt-page")
      end
    end

    def page_params
      attributes = [:slug, :more_info_flag, :print_content_flag, :status,
                    image_attributes: image_attributes]

      params.require(:site_customization_page).permit(*attributes,
        translation_params(SiteCustomization::Page)
      )
    end
end
