class DeviseMailer < Devise::Mailer
  helper :application, :settings, :mailer
  include Devise::Controllers::UrlHelpers
  default template_path: "devise/mailer"
  before_action :set_bcc # custom

  protected

    def devise_mail(record, action, opts = {})
      I18n.with_locale record.locale do
        super(record, action, opts)
      end
    end

    def set_bcc
      bcc_email = Rails.application.secrets.bcc_email

      if bcc_email.present?
        headers["bcc"] = bcc_email
      end
    end
end
