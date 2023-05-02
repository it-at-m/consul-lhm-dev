require_dependency Rails.root.join("app", "controllers", "application_controller").to_s

class ApplicationController < ActionController::Base
  before_action :set_projekts_for_overview_page_navigation,
                :set_default_social_media_images, :set_partner_emails
  before_action :show_launch_page, if: :show_launch_page?
  helper_method :set_comment_flags

  private

    def show_launch_page?
      launch_date_setting = Setting["extended_option.general.launch_date"]
      return false if launch_date_setting.blank?

      return false if current_user&.administrator?

      return false if allowed_public_actions?

      begin
        launch_date = Date.strptime(launch_date_setting, "%d.%m.%Y")
        launch_date > Date.today
      rescue Date::Error
        false
      end
    end

    def allowed_public_actions?
      (controller_name == "sessions" && action_name == "new") ||
        (controller_name == "passwords" && action_name.in?(%w[new edit create])) ||
        (controller_name == "confirmations" && action_name.in?(%w[new show create update])) ||
        (controller_name == "registrations" && action_name.in?(%w[new create success check_username cancel edit update destroy delete_form delete finish_signup do_finish_signup]))
    end

    def show_launch_page
      @header_launch = Widget::Card.header.find_by(title: "header_large_launch")
      render "welcome/launch", layout: "launch_page"
    end

    def all_selected_tags
      if params[:tags]
        params[:tags].split(",").map { |tag_name| Tag.find_by(name: tag_name) }.compact || []
      else
        []
      end
    end

    def set_projekts_for_overview_page_navigation
      @projekts_for_overview_page_navigation = Projekt.joins(:projekt_settings)
        .where(projekt_settings: { key: "projekt_feature.general.show_in_overview_page_navigation", value: "active" })
    end

    def set_default_social_media_images
      return if params[:controller] == "ckeditor/pictures"

      SiteCustomization::Image.all_images

      social_media_icon = SiteCustomization::Image.all.find_by(name: "social_media_icon").image

      if social_media_icon.attached?
        @social_media_icon_path = polymorphic_path(social_media_icon, disposition: "attachment").split("?")[0].delete_prefix("/")
      else
        @social_media_icon_path = nil
      end

      twitter_icon = SiteCustomization::Image.all.find_by(name: "social_media_icon_twitter").image

      if twitter_icon.attached?
        @social_media_icon_twitter_url = polymorphic_path(twitter_icon.attachment, disposition: "attachment")
          .split("?")[0]
      else
        nil
      end
    end

    def set_deficiency_report_votes(deficiency_reports)
      @deficiency_report_votes = current_user ? current_user.deficiency_report_votes(deficiency_reports) : {}
    end

    def set_projekts_for_selector
      @projekts = Projekt.top_level
    end

    def set_partner_emails
      filename = File.join(Rails.root, "config", "secret_emails.yml")
      @partner_emails = File.exist?(filename) ? File.readlines(filename).map { |l| l.chomp.downcase } : []
    end
end
