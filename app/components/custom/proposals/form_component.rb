require_dependency Rails.root.join("app", "components", "proposals", "form_component").to_s

class Proposals::FormComponent < ApplicationComponent
  delegate :projekt_feature?, :projekt_phase_feature?, to: :helpers
  def initialize(proposal, url:, selected_projekt:)
    @proposal = proposal
    @url = url
    @selected_projekt = selected_projekt
  end
end
