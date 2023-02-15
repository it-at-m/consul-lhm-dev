require_dependency Rails.root.join("app", "controllers", "account_controller").to_s

class AccountController < ApplicationController
  private

    def allowed_params
      if @account.organization?
        [:phone_number, :email_on_comment, :email_on_comment_reply, :newsletter,
         organization_attributes: [:name, :responsible_name]]
      else
        [
         :username, :public_activity, :public_interests, :email_on_comment,
         :email_on_comment_reply, :email_on_direct_message, :email_digest, :newsletter,
         :official_position_badge, :recommended_debates, :recommended_proposals,
         :adm_email_on_new_comment, :adm_email_on_new_proposal,
         :adm_email_on_new_debate, :adm_email_on_new_deficiency_report,
         :adm_email_on_new_manual_verification
        ]
      end
    end
end
