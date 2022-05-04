require_dependency Rails.root.join("app", "controllers", "dashboard", "base_controller").to_s

class Dashboard::BaseController < ApplicationController
  helper_method :custom_votes_for_proposal_success

  private
    def next_goal_supports(proposal)
      @next_goal_supports ||= next_goal&.required_supports || custom_votes_for_proposal_success(proposal) || Setting["votes_for_proposal_success"]
    end

    def next_goal_progress
      @next_goal_progress ||= (proposal.votes_for.size * 100) / next_goal_supports(proposal).to_i
    end

    def custom_votes_for_proposal_success(proposal)
      return nil unless proposal.projekt.present?
      return nil if ProjektSetting.find_by(projekt: proposal.projekt, key: "projekt_feature.proposal_options.votes_for_proposal_success").value.to_i == 0
      ProjektSetting.find_by(projekt: proposal.projekt, key: "projekt_feature.proposal_options.votes_for_proposal_success").value.to_i
    end
end
