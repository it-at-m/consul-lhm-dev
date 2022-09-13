require_dependency Rails.root.join("app", "helpers", "users_helper").to_s

module UsersHelper
  def proposal_limit_exceeded?(user)
    user.proposals.where(retired_at: nil).count >= Setting['extended_option.proposals.max_active_proposals_per_user'].to_i
  end

  def ck_editor_class(current_user)
   if extended_feature?("general.extended_editor_for_admins") && current_user.administrator?
     'extended-a'
   elsif extended_feature?("general.extended_editor_for_users") && !current_user.administrator?
     'extended-u'
   else
     'regular'
   end
  end

  def skip_user_verification?
    Setting["feature.user.skip_verification"].present?
  end

  def show_admin_menu?(user = nil)
    unless namespace == "officing"
      current_administrator? || current_moderator? || current_valuator? || current_manager? ||
        user&.administrator? || current_poll_officer? || current_sdg_manager? ||
        user&.projekt_manager?
    end
  end

  def options_for_gender_select
    [
      [t("custom.devise_views.users.gender.male"), "male"],
      [t("custom.devise_views.users.gender.female"), "female"]
    ]
  end

  def custom_admin_root_path(user)
    return projekt_management_root_path if user.projekt_manager? && !user.administrator?

    admin_root_path
  end
end
