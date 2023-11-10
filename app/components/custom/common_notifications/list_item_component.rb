class CommonNotifications::ListItemComponent < ApplicationComponent
  def initialize(notification:, enable_moderation_actions: true, show_admin_actions: false)
    @notification = notification
    @enable_moderation_actions = enable_moderation_actions
    @show_admin_actions = show_admin_actions
  end

  def edit_path
    case @notification
    when ProposalNotification
      edit_proposal_notification_path(@notification)
    end
  end

  def delete_path
    case @notification
    when ProposalNotification
      proposal_notification_path(@notification)
    end
  end
end
