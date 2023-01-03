require_dependency Rails.root.join("app", "components", "admin", "votation_types", "fields_component").to_s

class Admin::VotationTypes::FieldsComponent < ApplicationComponent
  def initialize(form:)
    @form = form
    @votation_type = form.object
  end

  def hide_hint_class(votation_type_name)
    return "" if votation_type_name == @votation_type.vote_type
    return "" if (votation_type_name == "unique" && @votation_type.vote_type.nil?)

    "hide"
  end

  def hide_max_votes_input_class(votation_type_name)
    return "hide" if !VotationType.allowing_multiple_answers.include?(votation_type_name)
  end
end
