require_dependency Rails.root.join("app", "controllers", "account_controller").to_s

class AccountController < ApplicationController
  include ImageAttributes
  include HasRegisteredAddress

  respond_to :js, only: [:edit_username]

  def show
    @account_individial_groups_hard = IndividualGroup.hard
    @account_individial_groups_soft = IndividualGroup.soft
    @account_individual_group_values = @account.individual_group_values
    @notifications =
      if params[:notifications] == "read"
        current_user.notifications.read
      else
        current_user.notifications.unread
      end

    if Setting.new_design_enabled?
      render :show_new
    else
      render :show
    end
  end

  def refresh_activities; end

  def edit_username; end

  def update_username
    unless params["user"]["cancel_changes"] == "true"
      @account.update(username: params["user"]["username"])
    end
  end

  def update
    if @account.update(account_params)
      respond_to do |format|
        format.html do
          redirect_to account_path, notice: t("flash.actions.save_changes.notice")
        end
        format.js do
          render
        end
      end
    else
      @account.errors.messages.delete(:organization)
      render :show
    end
  end

  def edit_details
    head :not_found unless @account.extended_registration?

    @registered_address_city = @account.registered_address_city
    @registered_address_street = @account.registered_address_street
    @registered_address = @account.registered_address
    if @registered_address_city.blank?
      @selected_city_id = "0" if @registered_address_city.blank?
      @account.form_registered_address_city_id = "0"
    end
  end

  def update_details
    head :not_found unless @account.extended_registration?

    process_temp_attributes_for(@account)
    set_address_objects_from_temp_attributes_for(@account)

    if @account.extended_registration? && @account.errors.any?
      render :edit_details
    elsif @account.valid? && @account.update(user_params)
      @account.unverify!
      redirect_to account_path, notice: t("flash.actions.save_changes.notice")
    else
      render :edit_details
    end
  end

  private

    def account_params
      process_individual_group_values_param
      params.require(:account).permit(allowed_params)
    end

    def process_individual_group_values_param
      if params["account"]["individual_group_value_ids"].present?
        @account.individual_group_values.where(individual_group_id: IndividualGroup.hard).ids.each do |id|
          params["account"]["individual_group_value_ids"].push(id)
        end
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
         :background_image,
         individual_group_value_ids: [],
         image_attributes: image_attributes
        ]
      end
    end

    def user_params
      set_address_attributes

      params.require(:user).permit(
        :username,
        :first_name, :last_name,
        :city_name, :plz, :street_name, :street_number, :street_number_extension,
        :registered_address_id,
        :gender, :date_of_birth,
        :document_type, :document_last_digits
      )
    end
end
