module NotificationServices
  class NewCommentNotifier < ApplicationService
    def initialize(comment_id)
      @comment = Comment.find(comment_id)
    end

    def call
      users_to_notify_ids.each do |user_id|
        NotificationServiceMailer.new_comment(user_id, @comment.id).deliver_later
      end
    end

    private

      def users_to_notify_ids
        administrator_ids = User.joins(:administrator).where(adm_email_on_new_comment: true).ids
        moderator_ids = User.joins(:moderator).where(adm_email_on_new_comment: true).ids
        projekt_manager_ids = User.joins(projekt_manager: :projekts).where(adm_email_on_new_comment: true)
          .where(projekt_managers: { projekts: { id: @comment&.projekt&.id }}).ids

        [administrator_ids, moderator_ids, projekt_manager_ids].flatten.uniq
      end
  end
end
