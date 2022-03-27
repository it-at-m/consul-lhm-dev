class ChangeCustomAnalyticsCookieEnabled < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :custom_analytics_cookies_enabled, :boolean, default: nil
    rename_column :users, :custom_analytics_cookies_enabled, :custom_statistic_cookies_enabled
  end
end
