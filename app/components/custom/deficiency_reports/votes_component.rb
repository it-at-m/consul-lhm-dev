class DeficiencyReports::VotesComponent < ApplicationComponent
  attr_reader :deficiency_report
  delegate :current_user, :user_signed_in?, :link_to_signin, :link_to_signup, to: :helpers

  def initialize(deficiency_report)
    @deficiency_report = deficiency_report
  end

  private

    def can_vote?
      deficiency_report.votable_by?(current_user)
    end

    def cannot_vote_text
      return if can_vote?

      if !user_signed_in?
        sanitize(t("custom.users.login_to_vote", signin: link_to_signin, signup: link_to_signup))

      elsif current_user.organization?
        t("votes.organizations")

      else
        t("custom.votes.not_votable")

      end
    end
end
