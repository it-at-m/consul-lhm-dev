class DeficiencyReportMailer < ApplicationMailer
  def notify_administrators_about_new_deficiency_report(deficiency_report)
    @deficiency_report = deficiency_report
    subject = t("custom.deficiency_reports.mailers.notify_administrators_about_new_deficiency_report.subject")

    Administrator.all.each do |admin|
      with_user(admin.user) do
        mail(to: admin.email, subject: subject)
      end
    end
  end

  def notify_administrators_about_answer_update(deficiency_report)
    @deficiency_report = deficiency_report
    subject = t("custom.deficiency_reports.mailers.notify_administrators_about_answer_update.subject")

    Administrator.all.each do |admin|
      with_user(admin.user) do
        mail(to: admin.email, subject: subject)
      end
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
    subject = t("custom.deficiency_reports.mailers.notify_officer.subject")
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
