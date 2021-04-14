require_dependency Rails.root.join("app", "helpers", "comments_helper").to_s

module CommentsHelper
  def hide_comment_replies_by_default?
    if Setting["extended_feature.hide_comment_replies_by_default"]
      ' js-hide-comment-replies-by-default'
    else
      ''
    end
  end
end
