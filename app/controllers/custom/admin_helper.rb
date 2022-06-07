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
end
