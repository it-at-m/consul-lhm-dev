require_dependency Rails.root.join("app", "components", "comments", "votes_component").to_s

class Comments::VotesComponent < ApplicationComponent
  delegate :current_user, :user_signed_in?, :link_to_signin, :link_to_signup, :projekt_feature?, to: :helpers

  private

    def can_vote?
      comment.votable_by?(current_user)
    end

    def allow_downvoting?
      if comment.commentable.is_a?(Projekt)
        projekt_feature?(comment.commentable, "general.allow_downvoting_comments")

      elsif comment.commentable.is_a?(Debate)
        projekt_feature?(comment.commentable.projekt, "debates.allow_downvoting")

      else
        true
      end
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
