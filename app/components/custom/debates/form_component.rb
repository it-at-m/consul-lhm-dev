require_dependency Rails.root.join("app", "components", "debates", "form_component").to_s

class Debates::FormComponent < ApplicationComponent
  delegate :current_user, to: :helpers

  def initialize(debate, selected_projekt:)
    @debate = debate
    @selected_projekt = selected_projekt
  end

  def categories
    Tag.category.order(:name)
  end
end
