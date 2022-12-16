class RemoveCustomStatisticCookiesEnabledFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :custom_statistic_cookies_enabled, :boolean, default: nil
  end
end
