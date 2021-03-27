require_dependency Rails.root.join("app", "controllers", "admin", "settings_controller").to_s

class Admin::SettingsController < Admin::BaseController

  private
    def request_referer
      return request.referer + "#tab-projekts-settings" if request.referer.include?('admin/projekts')
      return request.referer + params[:setting][:tab] if params[:setting][:tab]

      request.referer
    end
end
