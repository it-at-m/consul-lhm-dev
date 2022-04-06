Warden::Manager.after_set_user do |user,auth,opts|
  if (user.custom_statistic_cookies_enabled == nil ||
      auth.cookies['statistic_cookies_just_set'] == 'true')

    auth.cookies[:statistic_cookies_just_set] = 'false'

    user.update_attribute(
      :custom_statistic_cookies_enabled,
      auth.cookies['statistic_cookies_enabled'] == 'true'
    )
  end
end
