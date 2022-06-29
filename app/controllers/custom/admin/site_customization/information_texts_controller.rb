require_dependency Rails.root.join("app", "controllers", "admin", 'site_customization', "information_texts_controller").to_s

class Admin::SiteCustomization::InformationTextsController < Admin::SiteCustomization::BaseController

  def index
    @content = I18nContent.all_translation_strings
  end
end
