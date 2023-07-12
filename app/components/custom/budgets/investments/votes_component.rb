require_dependency Rails.root.join("app", "components", "budgets", "investments", "votes_component").to_s

class Budgets::Investments::VotesComponent < ApplicationComponent
  delegate :link_to_signin, :link_to_signup, :link_to_verify_account, :projekt_feature?, :projekt_phase_feature?, to: :helpers

  private

    def cannot_vote_text
      if reason == :not_logged_in
        t(path_to_key,
          sign_in: link_to_signin, sign_up: link_to_signup)

      elsif reason.present?
        t(path_to_key,
          verify: link_to_verify_account,
          city: Setting["org_name"],
          geozones: investment.budget.projekt_phase.geozone_restrictions_formatted,
          age_restriction: investment.budget.projekt_phase.age_restriction_formatted,
          restricted_streets: investment.budget.projekt_phase.street_restrictions_formatted,
          individual_group_values: investment.budget.projekt_phase.individual_group_value_restriction_formatted
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
