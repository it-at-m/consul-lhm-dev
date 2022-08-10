require_dependency Rails.root.join("app", "helpers", "admin_helper").to_s

module AdminHelper
  def dashboard_index_back_path
    if controller_name == 'projekts' &&
        action_name == 'edit' &&
        @projekt.present? &&
        @projekt.page.present? &&
        @projekt.page.status == 'published'
      page_path(@projekt.page.slug)

    elsif controller_name == 'pages' &&
        action_name == 'edit' &&
        @page.present? &&
        @page.status == 'published'
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

  def redirect_to_projekt_questions_path(projekt)
    edit_admin_projekt_path(projekt, anchor: "tab-projekt-questions")
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
end
