require_dependency Rails.root.join("app", "models", "comment_notifier").to_s

class CommentNotifier

  private

    def email_on_comment?
      commentable_author = @comment.commentable.author

      return false unless commentable_author.present?

      commentable_author != @author && commentable_author.email_on_comment?
    end

    def email_on_comment_reply?
      return false unless @comment.reply?

      parent_author = @comment.parent.author

      return false unless parent_author.present?

      parent_author != @author && parent_author.email_on_comment_reply?
    end
end
