class ApplicationMailer < ActionMailer::Base
  helper :settings
  helper :application
  default from: proc { "#{Setting["mailer_from_name"]} <#{Setting["mailer_from_address"]}>" }
  layout "mailer"
  before_action :set_bcc # custom

  private

    def set_bcc
      bcc_email = Rails.application.secrets.bcc_email

      if bcc_email.present?
        headers["bcc"] = bcc_email
      end
    end
end
