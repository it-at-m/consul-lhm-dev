class Shared::ProjektLabelsComponent < ApplicationComponent
  delegate :toggle_element_in_array, to: :helpers

  def initialize(projekt_phase_id: nil, resource: nil)
    if projekt_phase_id
      @projekt_phase = ProjektPhase.find(projekt_phase_id)
      @projekt_labels = @projekt_phase.projekt_labels
    elsif resource
      @projekt_phase = resource.projekt_phase
      @projekt_labels = resource.projekt_labels
    end
  end

  def filter_link?
    controller_name == "pages"
  end

  def label_selected?(label)
    params[:projekt_label_ids].present? && params[:projekt_label_ids].include?(label.id.to_s)
  end

  def link_path(label)
    selected_projekt_labels = params[:projekt_label_ids].dup
    url_to_footer_tab(remote: true, projekt_label_ids: toggle_element_in_array(selected_projekt_labels, label.id.to_s))
  end

  def footer_tab_back_button_url(label)
    selected_projekt_labels = params[:projekt_label_ids].dup

    if controller_name == "pages" &&
        !helpers.request.path.starts_with?("/projekts")

      url_to_footer_tab(projekt_label_ids: toggle_element_in_array(selected_projekt_labels, label.id.to_s))
    else
      "empty"
    end
  end
end
