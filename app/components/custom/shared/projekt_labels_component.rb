class Shared::ProjektLabelsComponent < ViewComponent::Base
  def initialize(projekt_id:, css_class: nil, scope: :all)
    @projekt = Projekt.find(projekt_id)
    @css_class = css_class
    @projekt_labels = scope == :all ? @projekt.all_projekt_labels : @projekt.projekt_labels
  end

  def render?
    @projekt_labels.any?
  end

  def label_grayscale?
    @css_class.in? %w[js-select-projekt-label]
  end
end
