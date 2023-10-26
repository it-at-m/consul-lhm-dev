require_dependency Rails.root.join("app", "controllers", "admin", "settings_controller").to_s

class Admin::SettingsController < Admin::BaseController
  def index
    all_settings = Setting.all.group_by(&:type)
    @configuration_settings = all_settings["configuration"]
    @feature_settings = all_settings["feature"]

    @extended_feature_general = all_settings["extended_feature.general"]
    @extended_feature_gdpr = all_settings["extended_feature.gdpr"]
    @extended_feature_modulewide = all_settings["extended_feature.modulewide"]
    @extended_feature_debates = all_settings["extended_feature.debates"]
    @extended_feature_proposals = all_settings["extended_feature.proposals"]
    @extended_feature_polls = all_settings["extended_feature.polls"]

    @extended_option_general = all_settings["extended_option.general"]
    @extended_option_gdpr = all_settings["extended_option.gdpr"]
    @extended_option_proposals = all_settings["extended_option.proposals"]

    @extra_fields_registration = all_settings["extra_fields.registration"]
    extra_fields_refistration_extended = @extra_fields_registration.find { |setting| setting.key == "extra_fields.registration.extended" }
    extra_fields_registration_check_documents = @extra_fields_registration.find { |setting| setting.key == "extra_fields.registration.check_documents" }
    extra_fields_refistration_extended.dependent_setting_ids = extra_fields_registration_check_documents.id
    extra_fields_refistration_extended.dependent_setting_action = "disable-when-disabled"
    unless extra_fields_refistration_extended.enabled?
      extra_fields_registration_check_documents.form_field_disabled = true
    end

    @extra_fields_verification = all_settings["extra_fields.verification"]
    extra_fields_verification_check_documents = @extra_fields_verification.find { |setting| setting.key == "extra_fields.verification.check_documents" }
    skip_verification_setting = Setting.find_by(key: "feature.user.skip_verification")
    skip_verification_setting.dependent_setting_ids = extra_fields_verification_check_documents.id
    skip_verification_setting.dependent_setting_action = "disable-when-enabled"
    if skip_verification_setting.enabled?
      extra_fields_verification_check_documents.form_field_disabled = true
    end
    @extra_fields_verification.unshift(skip_verification_setting)

    @participation_processes_settings = all_settings["process"]
    @map_configuration_settings = all_settings["map"]
    @proposals_settings = all_settings["proposals"]
    @remote_census_general_settings = all_settings["remote_census.general"]
    @remote_census_request_settings = all_settings["remote_census.request"]
    @remote_census_response_settings = all_settings["remote_census.response"]
    @uploads_settings = all_settings["uploads"]
    @sdg_settings = all_settings["sdg"]

    if !Rails.application.secrets.new_design_enabled
      @extended_feature_general =
        @extended_feature_general
          .filter { |e|
            [
              "extended_feature.general.enable_projekt_events_page",
              "extended_feature.general.enable_google_translate"
            ].exclude?(e.key)
          }
    end
  end

  def update
    @setting = Setting.find(params[:id])
    @setting.update!(settings_params)
    update_dependent_settings

    respond_to do |format|
      format.html { redirect_to request_referer, notice: t("admin.settings.flash.updated") }
      format.js
    end
  end

  def update_map
    Setting["map.latitude"] = params[:latitude].to_f
    Setting["map.longitude"] = params[:longitude].to_f
    Setting["map.zoom"] = params[:zoom].to_i
    redirect_to request_referer, notice: t("admin.settings.index.map.flash.update")
  end

  private

    def request_referer
      return request.referer + params[:setting][:tab] if params[:setting] && params[:setting][:tab]
      return request.referer + params[:tab] if params[:tab]

      request.referer
    end

    def allowed_params
      [:value, :dependent_setting_ids, :dependent_setting_action]
    end

    def update_dependent_settings
      return if @setting.dependent_setting_ids.nil?

      dependent_setting_ids = @setting.dependent_setting_ids.split(",")

      @dependent_settings = Setting.where(id: dependent_setting_ids)

      if (@setting.dependent_setting_action == "disable-when-disabled" && !@setting.enabled?) ||
        (@setting.dependent_setting_action == "disable-when-enabled" && @setting.enabled?)

        @dependent_settings.update_all(value: "")
        @dependent_settings.each { |setting| setting.form_field_disabled = true }
      end
    end
end
