require_dependency Rails.root.join("app", "components", "debates", "form_component").to_s

class Debates::FormComponent < ApplicationComponent
  delegate :current_user, to: :helpers

  def categories
    Tag.category.order(:name)
  end
end
