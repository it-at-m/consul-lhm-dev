class Shared::ProjektLabelsComponent < ViewComponent::Base
  def initialize(projekt_id: nil, css_class: nil, scope: :all)
    @projekt = Projekt.find(projekt_id) if projekt_id
    @css_class = css_class
    @scope = scope
  end

  def render?
    projekt_labels.any?
  end

  def label_grayscale?
    @css_class.in? %w[js-select-projekt-label]
  end

  def projekt_labels
    return ProjektLabel.all unless @projekt

    @scope == :all ? @projekt.all_projekt_labels : @projekt.projekt_labels
  end
end
