module NotificationServices
  class NotAssignedDeficiencyReportsReminder < ApplicationService
    def initialize
      @threshold_date = 14.days.ago
    end

    def call
      return if reports_with_overdue_assignment_ids.blank?

      Administrator.all.find_each do |admin|
        NotificationServiceMailer.not_assigned_deficiency_reports(admin.id, reports_with_overdue_assignment_ids).deliver_later
      end
    end

    private

      def reports_with_overdue_assignment_ids
        DeficiencyReport.where(deficiency_report_officer_id: nil)
          .where(assigned_at: @threshold_date.midnight..@threshold_date.end_of_day)
          .ids
      end
  end
end
