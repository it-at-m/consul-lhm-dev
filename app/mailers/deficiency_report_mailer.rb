class DeficiencyReportMailer < ApplicationMailer
  def notify_administrators_about_new_deficiency_report(deficiency_report, admin_user)
    @deficiency_report = deficiency_report
    subject = t("custom.deficiency_reports.mailers.notify_administrators_about_new_deficiency_report.subject",
                identifier: "#{deficiency_report.id}: #{deficiency_report.title.first(50)}")

    with_user(admin_user) do
      mail(to: admin_user.email, subject: subject)
    end
  end

  def notify_administrators_about_answer_update(deficiency_report, admin_user)
    @deficiency_report = deficiency_report
    subject = t("custom.deficiency_reports.mailers.notify_administrators_about_answer_update.subject",
                identifier: "#{deficiency_report.id}: #{deficiency_report.title.first(50)}")

    with_user(admin_user) do
      mail(to: admin_user.email, subject: subject)
    end
  end

  def notify_author_about_status_change(deficiency_report)
    @deficiency_report = deficiency_report
    subject = t("custom.deficiency_reports.mailers.notify_author_about_status_change.subject")

    @email_to = @deficiency_report.author.email

    with_user(@deficiency_report.author) do
      mail(to: @email_to, subject: subject)
    end
  end

  def notify_officer(deficiency_report)
    @deficiency_report = deficiency_report
    subject = t("custom.deficiency_reports.mailers.notify_officer.subject",
                identifier: "#{deficiency_report.id}: #{deficiency_report.title.first(50)}")
    @email_to = @deficiency_report.officer.email

    with_user(@deficiency_report.officer.user) do
      mail(to: @email_to, subject: subject) if @deficiency_report.officer.present?
    end
  end

  private

  def with_user(user)
    I18n.with_locale(user.locale) do
      yield
    end
  end
end
