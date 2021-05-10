require_dependency Rails.root.join("app", "controllers", "admin", "settings_controller").to_s

class Admin::SettingsController < Admin::BaseController
  def index
    all_settings = Setting.all.group_by(&:type)
    @configuration_settings = all_settings["configuration"]
    @feature_settings = all_settings["feature"]
    @extended_feature_settings = all_settings["extended_feature"]
    @extended_option_settings = all_settings["extended_option"]
    @participation_processes_settings = all_settings["process"]
    @map_configuration_settings = all_settings["map"]
    @proposals_settings = all_settings["proposals"]
    @remote_census_general_settings = all_settings["remote_census.general"]
    @remote_census_request_settings = all_settings["remote_census.request"]
    @remote_census_response_settings = all_settings["remote_census.response"]
    @uploads_settings = all_settings["uploads"]
    @sdg_settings = all_settings["sdg"]
  end

  private
    def request_referer
      return request.referer + "#tab-projekts-settings" if request.referer.include?('admin/projekts')
      return request.referer + params[:setting][:tab] if params[:setting][:tab]

      request.referer
    end
end
