# frozen_string_literal: true

module NotificationServices
  class NewCommentsDeficiencyReportsNotification < ApplicationService
    def initialize
      @threshold_date = 14.days.ago
    end

    def call
      DeficiencyReport.where(notify_officer_about_new_comments: true).find_each do |deficiency_report|
        next if deficiency_report.notified_officer_about_new_comments_datetime.to_date < 6.days.ago

        send_new_comments_email(deficiency_report)
      end
    end

    private

      def send_new_comments_email(deficiency_report)
        new_comments = deficiency_report.comments.created_after_date(
          deficiency_report.notified_officer_about_new_comments_datetime
        )

        last_notified_time = deficiency_report.notified_officer_about_new_comments_datetime

        deficiency_report.update!(notified_officer_about_new_comments_datetime: Time.current)

        if new_comments.exists?
          NotificationServiceMailer.new_comments_for_deficiency_report(
            deficiency_report,
            last_notified_time
          ).deliver_now
        end
      end
  end
end
