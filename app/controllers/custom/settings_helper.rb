require_dependency Rails.root.join("app", "helpers", "settings_helper").to_s

module SettingsHelper
  def extended_feature?(name)
    setting["extended_feature.#{name}"].presence
  end
end
