module NotificationServices
  class NewManualVerificationRequestNotifier < ApplicationService
    def initialize(user_to_verify_id)
      @user_to_verify_id = user_to_verify_id
    end

    def call
      users_to_notify_ids.each do |user_id|
        NotificationServiceMailer.new_manual_verification_request(user_id, @user_to_verify_id).deliver_later
      end
    end

    private

      def users_to_notify_ids
        User.joins(:administrator).where(adm_email_on_new_manual_verification: true).ids
      end
  end
end
