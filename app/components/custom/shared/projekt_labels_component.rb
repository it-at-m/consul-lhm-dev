class Shared::ProjektLabelsComponent < ViewComponent::Base
  delegate :pick_text_color, to: :helpers

  def initialize(projekt_id: nil, css_class: nil, scope: :all)
    @projekt = Projekt.find(projekt_id) if projekt_id
    @css_class = css_class
    @scope = scope
  end

  def render?
    projekt_labels.any?
  end

  def gray_by_default?
    @css_class.split && %w[js-select-projekt-label].any?
  end

  def label_background_color(label)
    return "#767676" if gray_by_default?

    label.color
  end

  def label_text_color(label)
    return "#ffffff" if gray_by_default?

    pick_text_color(label_background_color(label))
  end

  def projekt_labels
    return ProjektLabel.all unless @projekt

    @scope == :all ? @projekt.all_projekt_labels : @projekt.projekt_labels
  end
end
