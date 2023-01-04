require_dependency Rails.root.join("app", "components", "admin", "poll", "questions", "form_component").to_s

class Admin::Poll::Questions::FormComponent < ApplicationComponent
  def hide_rating_scale_labels_class(votation_type_name)
    return "hide" if votation_type_name != 'rating_scale'
  end
end
