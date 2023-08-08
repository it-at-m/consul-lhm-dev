require_dependency Rails.root.join("app", "helpers", "admin_helper").to_s

module AdminHelper
  def dashboard_index_back_path
    if params[:controller].in?(["admin/projekts", "admin/projekt_phases"]) &&
        @projekt.present? &&
        @projekt.page.present? &&
        @projekt.page.status == "published"
      page_path(@projekt.page.slug)

    elsif controller_name == "pages" &&
        action_name == "edit" &&
        @page.present? &&
        @page.status == "published"
      page_path(@page.slug)

    else
      root_path

    end
  end

  # path helpers for projekt questions

  def new_projekt_question_path(projekt_id, projekt_livestream_id: nil)
    if params[:controller].include?('projekt_management')
      new_projekt_management_projekt_projekt_question_path(
        projekt_id: projekt_id,
        projekt_livestream_id: projekt_livestream_id
      )
    else
      new_admin_projekt_projekt_question_path(
        projekt_id: projekt_id,
        projekt_livestream_id: projekt_livestream_id
      )
    end
  end

  def edit_projekt_question_path(projekt, question, **hash_arguments)
    if params[:controller].include?("projekt_management")
      edit_projekt_management_projekt_projekt_question_path(projekt, question, **hash_arguments)
    else
      edit_admin_projekt_projekt_question_path(projekt, question, **hash_arguments)
    end
  end

  def edit_admin_projekt_path(projekt, **hash_arguments)
    if params[:controller].include?("projekt_management")
      edit_projekt_management_projekt_path(projekt, **hash_arguments)
    else
      super(projekt, **hash_arguments)
    end
  end

  def admin_projekt_livestreams_path(projekt)
    edit_admin_projekt_path(projekt, anchor: "tab-projekt-livestreams")
  end

  def static_subnav_link_current?(link)
    action_name == link ? "current" : ""
  end

  # sorting user profiles
  def link_to_users_sorted_by(column)
    direction = set_direction(params[:direction])
    icon = set_sorting_icon(direction, column)

    translation = t("custom.admin.users.columns.#{column}")

    link_to(
      safe_join([translation, tag.span(class: "icon-sortable #{icon}")]),
      admin_users_path(sort_by: column, direction: direction, filter: params[:filter], page: params[:page], search: params[:search])
    )
  end
end
