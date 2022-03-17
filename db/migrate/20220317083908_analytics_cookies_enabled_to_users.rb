class AnalyticsCookiesEnabledToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :custom_analytics_cookies_enabled, :boolean, default: false
  end
end
