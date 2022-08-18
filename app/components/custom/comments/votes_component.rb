require_dependency Rails.root.join("app", "components", "comments", "votes_component").to_s

class Comments::VotesComponent < ApplicationComponent
  delegate :cannot?, :projekt_feature?, to: :helpers

  private

    def allow_downvoting?
      if comment.commentable.is_a?(Projekt)
        projekt_feature?(comment.commentable, "general.allow_downvoting_comments")

      else
        projekt_feature?(comment.commentable.projekt, "general.allow_downvoting_comments")

      end
    end
end
