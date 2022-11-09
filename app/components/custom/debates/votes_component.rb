require_dependency Rails.root.join("app", "components", "debates", "votes_component").to_s

class Debates::VotesComponent < ApplicationComponent
  delegate :user_signed_in?, :link_to_signin, :link_to_signup,
           :link_to_verify_account_short, to: :helpers

  private

    def cannot_vote_text
      return if can_vote?

      if !user_signed_in?
        sanitize(t("custom.users.login_to_vote", signin: link_to_signin, signup: link_to_signup))

      elsif debate.debate_phase.geozone_restricted == "only_citizens" && current_user&.not_current_city_citizen?
        t("custom.shared.warnings.only_for_citizens", city: Setting["org_name"])

      elsif debate.debate_phase.geozone_restricted == "only_geozones" && !debate.debate_phase.geozone_restrictions.include?(current_user&.geozone)
        t("custom.shared.warnings.only_for_geozones", geozones: debate.debate_phase.geozone_restrictions_formatted)

      elsif current_user.organization?
        t("votes.organizations")

      elsif !current_user.level_two_or_three_verified?
        sanitize(t("custom.votes.not_verified", verify_account: link_to_verify_account_short))

      else
        t("custom.votes.not_votable")

      end
    end
end
