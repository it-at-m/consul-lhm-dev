class NotificationServiceMailer < ApplicationMailer
  def overdue_deficiency_reports(officer_id, overdue_reports_ids)
    @officer = DeficiencyReport::Officer.find(officer_id)
    @overdue_reports = DeficiencyReport.where(id: overdue_reports_ids)

    subject = t("custom.notification_service_mailers.overdue_deficiency_reports.subject")

    with_user(@officer.user) do
      mail(to: @officer.email, subject: subject)
    end
  end

  def not_assigned_deficiency_reports(admin_id, not_assigned_reports_ids)
    @admin = Administrator.find(admin_id)
    @not_assigned_reports = DeficiencyReport.where(id: not_assigned_reports_ids)

    subject = t("custom.notification_service_mailers.not_assigned_deficiency_reports.subject")

    with_user(@admin.user) do
      mail(to: @admin.email, subject: subject)
    end
  end

  def new_proposal(user_id, proposal_id)
    @user = User.find(user_id)
    @proposal = Proposal.find(proposal_id)

    subject = t("custom.notification_service_mailers.new_proposal.subject")

    with_user(@user) do
      mail(to: @user.email, subject: subject)
    end
  end

  def new_debate(user_id, debate_id)
    @user = User.find(user_id)
    @debate = Debate.find(debate_id)

    subject = t("custom.notification_service_mailers.new_debate.subject")

    with_user(@user) do
      mail(to: @user.email, subject: subject)
    end
  end

  private

    def with_user(user)
      I18n.with_locale(user.locale) do
        yield
      end
    end
end
