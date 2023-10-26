require_dependency Rails.root.join("app", "helpers", "settings_helper").to_s

module SettingsHelper
  def extended_feature?(name)
    setting["extended_feature.#{name}"].present?
  end

  def deficiency_reports_feature?(name)
    setting["deficiency_reports.#{name}"].presence
  end

  # form permissions
  def allowed_to_post_on_behalf_of?(current_user, projekt)
    return true if current_user.administrator? || current_user.moderator?

    current_user.projekt_manager? && current_user.projekt_manager.allowed_to?(:create_on_behalf_of, projekt)
  end
end
