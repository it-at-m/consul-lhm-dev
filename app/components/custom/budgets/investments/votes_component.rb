require_dependency Rails.root.join("app", "components", "budgets", "investments", "votes_component").to_s

class Budgets::Investments::VotesComponent < ApplicationComponent
  delegate :link_to_signin, :link_to_signup, :link_to_verify_account, :projekt_feature?, to: :helpers

  private

    def cannot_vote_text
      if reason == :not_logged_in
        t(path_to_key,
          sign_in: link_to_signin, sign_up: link_to_signup)

      elsif reason.present?
        t(path_to_key,
          verify: link_to_verify_account,
          city: Setting["org_name"],
          geozones: investment.budget.budget_phase.geozone_restrictions_formatted,
          age_restriction: investment.budget.budget_phase.age_restriction_formatted,
          restricted_streets: investment.budget.budget_phase.street_restrictions_formatted
         )
      end
    end

    def path_to_key
      if I18n.exists?("custom.projekt_phases.permission_problem.votes_component.budget_phase.#{reason}")
        "custom.projekt_phases.permission_problem.votes_component.budget_phase.#{reason}"
      else
        "custom.projekt_phases.permission_problem.votes_component.shared.#{reason}"
      end
    end
end
