require_dependency Rails.root.join("app", "controllers", "notifications_controller").to_s

class NotificationsController < ApplicationController

  private

    def linkable_resource_path(notification)
      if notification.linkable_resource.is_a?(AdminNotification)
        notification.linkable_resource.link || notifications_path
      elsif notification.notifiable.is_a?(ProjektQuestion)
        "/#{notification.notifiable.projekt.page.slug}?selected_phase_id=#{notification.notifiable.projekt.question_phase.id}#filter-subnav"
      else
        polymorphic_path(notification.linkable_resource)
      end
    end
end
