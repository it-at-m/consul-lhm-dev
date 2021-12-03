class Admin::DeficiencyReports::SettingsController < Admin::BaseController
  def index
    @settings = Setting.all.group_by(&:type)['deficiency_reports']
  end
end
