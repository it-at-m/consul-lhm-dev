class Proposals::NewVotesComponent < ApplicationComponent
  attr_reader :proposal
  delegate :current_user, :link_to_verify_account, to: :helpers
  delegate :user_signed_in?, :link_to_signin, :link_to_signup,
           :link_to_verify_account_short, :projekt_feature?, to: :helpers

  def initialize(proposal, vote_url: nil)
    @proposal = proposal
    @vote_url = vote_url
  end

  def vote_url
    @vote_url || vote_proposal_path(proposal, value: "yes")
  end

  private

    def voted?
      current_user&.voted_for?(proposal)
    end

    def can_vote?
      proposal.votable_by?(current_user)
    end

    def support_aria_label
      t("proposals.proposal.support_label", proposal: proposal.title)
    end

    def cannot_vote_text
      return if can_vote?

      if !user_signed_in?
        sanitize(t("custom.users.login_to_vote", signin: link_to_signin, signup: link_to_signup))

      elsif current_user.organization?
        t("votes.organizations")

      elsif !current_user.level_two_or_three_verified?
        sanitize(t("custom.votes.not_verified", verify_account: link_to_verify_account_short))

      elsif proposal.proposal_phase &&
        (proposal.proposal_phase.geozone_restrictions.any? &&
          !proposal.proposal_phase.geozone_restrictions.include?(current_user.geozone))
        t("custom.votes.geo_restricted")

      else
        t("custom.votes.not_votable")

      end
    end
end
