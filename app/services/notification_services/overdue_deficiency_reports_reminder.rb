module NotificationServices
  class OverdueDeficiencyReportsReminder < ApplicationService
    def initialize
      @threshold_date = 14.days.ago
    end

    def call
      return if officers_with_overdue_reports_ids.blank?

      officers_with_overdue_reports_ids.each do |officer_id|
        overdue_report_ids_for_officer = overdue_reports.where(deficiency_report_officer_id: officer_id).ids
        NotificationServiceMailer.overdue_deficiency_reports(officer_id, overdue_report_ids_for_officer).deliver_later
      end
    end

    private

      def overdue_reports
        @overdue_reports = DeficiencyReport.where(official_answer: nil)
                             .where(assigned_at: @threshold_date.midnight..@threshold_date.end_of_day)
      end

      def officers_with_overdue_reports_ids
        @officers_with_overdue_reports_ids = overdue_reports
                                               .joins(:officer)
                                               .pluck("deficiency_report_officers.id")
                                               .compact.uniq
      end
  end
end
