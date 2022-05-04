Warden::Manager.after_set_user do |user,auth,opts|
  if (user.custom_statistic_cookies_enabled.nil? ||
      auth.cookies['statistic_cookies_setting_just_changed'] == 'true')

    auth.cookies[:statistic_cookies_setting_just_changed] = 'false'

    user.update_attribute(
      :custom_statistic_cookies_enabled,
      auth.cookies['statistic_cookies_enabled'] == 'true'
    )
  end

  if auth.cookies['statistic_cookies_enabled'].nil? && !user.custom_statistic_cookies_enabled.nil?
    auth.cookies['statistic_cookies_enabled'] = user.custom_statistic_cookies_enabled.to_s
  end
end
