class Shared::ProjektLabelsComponent < ApplicationComponent
  delegate :pick_text_color, :toggle_element_in_array, to: :helpers

  def initialize(projekt_id: nil, css_class: nil, scope: :all, resource: nil, sidebar_filter_link: false)
    @projekt = Projekt.find(projekt_id) if projekt_id
    @css_class = css_class
    @scope = scope
    @resource = resource
    @sidebar_filter_link = sidebar_filter_link
  end

  def render?
    projekt_labels.any?
  end

  def gray_by_default?(label)
    if params[:projekt_label_ids].present?
      !params[:projekt_label_ids].include?(label.id.to_s)

    elsif @css_class.present?
      @css_class.split && %w[js-select-projekt-label js-sidebar-filter-projekt-label].any?

    else
      false

    end
  end

  def label_background_color(label)
    return "#767676" if gray_by_default?(label)

    label.color
  end

  def label_text_color(label)
    return "#ffffff" if gray_by_default?(label)

    pick_text_color(label_background_color(label))
  end

  def projekt_labels
    return @resource.projekt_labels if @resource

    return ProjektLabel.all unless @projekt

    case @scope
    when :all
      @projekt.all_projekt_labels
    when :all_in_tree
      @projekt.all_projekt_labels_in_tree
    else
      @projekt.projekt_labels
    end
  end

  def link_path(label)
    selected_projekt_labels = params[:projekt_label_ids].dup

    url_for(action: params[:current_tab_path],
            controller: "/pages",
            page: params[:page] || 1,
            order: params[:order],
            filter_projekt_ids: params[:filter_projekt_ids],
            projekt_label_ids: toggle_element_in_array(selected_projekt_labels, label.id.to_s),
            filter: params[:filter])
  end

  def footer_tab_back_button_url(label)
    selected_projekt_labels = params[:projekt_label_ids].dup

    if controller_name == "pages" &&
        params[:current_tab_path].present? &&
        !helpers.request.path.starts_with?("/projekts")

      url_for_footer_tab_back_button(page_id: params[:id],
                                     pagination_page: params[:page],
                                     current_tab_path: params[:current_tab_path],
                                     filter: params[:filter],
                                     order: params[:order],
                                     filter_projekt_ids: params[:filter_projekt_ids],
                                     projekt_label_ids: toggle_element_in_array(selected_projekt_labels, label.id.to_s))
    else
      "empty"
    end
  end
end
