require_dependency Rails.root.join("app", "components", "shared", "comments_component").to_s

class Shared::AnalyticsCookieBannerComponent < ApplicationComponent
  def statistic_enabled?
    (
      view_context.cookies['statistic_cookies_enabled'] == 'true' ||
      view_context.current_user&.custom_statistic_cookies_enabled
    )
  end
end
