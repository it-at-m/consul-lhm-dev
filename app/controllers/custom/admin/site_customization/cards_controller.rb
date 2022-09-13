require_dependency Rails.root.join("app", "controllers", "admin", 'site_customization', "cards_controller").to_s

class Admin::SiteCustomization::CardsController < Admin::SiteCustomization::BaseController

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
      if @page.projekt.present? && @page.published? && params[:site_customization_page][:origin] == 'public_page'
        page_path(@page.slug)
      elsif @page.projekt.present?
        namespace = params[:controller].split('/').first

        namespaced_polymorphic_path(namespace, @page.projekt, action: :edit)
      else
        admin_site_customization_pages_path
      end
    end

    def index_path
      namespaced_polymorphic_path(params[:controller].split('/').first, @page.cards.new)
    end
end
