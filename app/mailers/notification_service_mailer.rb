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

  def new_comment(user_id, comment_id)
    @user = User.find(user_id)
    @comment = Comment.find(comment_id)

    subject = t("custom.notification_service_mailers.new_comment.subject")

    with_user(@user) do
      mail(to: @user.email, subject: subject)
    end
  end

  def new_deficiency_report(user_id, deficiency_report_id)
    @user = User.find(user_id)
    @deficiency_report = DeficiencyReport.find(deficiency_report_id)

    subject = t("custom.notification_service_mailers.new_deficiency_report.subject",
                identifier: "#{@deficiency_report.id}: #{@deficiency_report.title.first(50)}")

    with_user(@user) do
      mail(to: @user.email, subject: subject)
    end
  end

  def new_manual_verification_request(user_to_notify_id, user_to_verify_id)
    @user_to_notify = User.find(user_to_notify_id)
    @user_to_verify = User.find(user_to_verify_id)

    subject = t("custom.notification_service_mailers.new_manual_verification_request.subject")

    with_user(@user_to_notify) do
      mail(to: @user_to_notify.email, subject: subject)
    end
  end

  private

    def with_user(user)
      I18n.with_locale(user.locale) do
        yield
      end
    end
end
