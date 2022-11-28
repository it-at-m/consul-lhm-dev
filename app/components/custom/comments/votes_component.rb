require_dependency Rails.root.join("app", "components", "comments", "votes_component").to_s

class Comments::VotesComponent < ApplicationComponent
  delegate :cannot?, :projekt_feature?, :current_user, to: :helpers

  private

    def allow_downvoting?
      if comment.commentable.is_a?(Projekt)
        projekt_feature?(comment.commentable, "general.allow_downvoting_comments")

      elsif comment.commentable.is_a?(DeficiencyReport) || comment.commentable.is_a?(Legislation::Annotation)
        true

      else
        projekt_feature?(comment.commentable.projekt, "general.allow_downvoting_comments")

      end
    end

    def thumb_up_class
      return "voted_up" if current_user&.voted_up_on?(comment)
    end

    def thumb_down_class
      return "voted_down" if current_user&.voted_down_on?(comment)
    end
end
