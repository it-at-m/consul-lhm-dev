require_dependency Rails.root.join("app", "controllers", "account_controller").to_s

class AccountController < ApplicationController
  def show
    @account_individial_groups_hard = IndividualGroup.hard
    @account_individial_groups_soft = IndividualGroup.soft
    @account_individual_group_values = @account.individual_group_values
  end

  private

    def account_params
      process_individual_group_values_param
      params.require(:account).permit(allowed_params)
    end

    def process_individual_group_values_param
      @account.individual_group_values.where(individual_group_id: IndividualGroup.hard).ids.each do |id|
        params["account"]["individual_group_value_ids"].push(id)
      end
    end

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
         :adm_email_on_new_manual_verification,
         individual_group_value_ids: []
        ]
      end
    end
end
