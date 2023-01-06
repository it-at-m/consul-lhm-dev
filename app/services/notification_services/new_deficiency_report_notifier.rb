module NotificationServices
  class NewDeficiencyReportNotifier < ApplicationService
    def initialize(deficiency_report_id)
      @deficiency_report = DeficiencyReport.find(deficiency_report_id)
    end

    def call
      users_to_notify_ids.each do |user_id|
        NotificationServiceMailer.new_deficiency_report(user_id, @deficiency_report.id).deliver_later
      end
    end

    private

      def users_to_notify_ids
        administrator_ids = User.joins(:administrator).where(adm_email_on_new_deficiency_report: true).ids
        moderator_ids = User.joins(:moderator).where(adm_email_on_new_deficiency_report: true).ids

        [administrator_ids, moderator_ids].flatten.uniq
      end
  end
end
