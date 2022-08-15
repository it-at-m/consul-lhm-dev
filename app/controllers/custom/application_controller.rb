require_dependency Rails.root.join("app", "controllers", "application_controller").to_s

class ApplicationController < ActionController::Base
  before_action :set_top_level_projekts_for_menu, :set_default_social_media_images, :set_partner_emails
  before_action :show_launch_page, if: :show_launch_page?
  helper_method :set_comment_flags

  private

    def show_launch_page?
      return false if user_signed_in?
      return false if controller_name == "sessions" && action_name == "new"

      launch_date_setting = Setting["extended_option.general.launch_date"]
      return false if launch_date_setting.blank?

      begin
        launch_date = Date.strptime(launch_date_setting, "%d.%m.%Y")
        launch_date > Date.today
      rescue Date::Error
        false
      end
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

    def set_top_level_projekts_for_menu
      @top_level_projekts_for_menu = Projekt.top_level_navigation
    end

    def set_default_social_media_images
      SiteCustomization::Image.all_images

      social_media_icon = SiteCustomization::Image.all.find_by(name: "social_media_icon").image

      if social_media_icon.attached?
        @social_media_icon_path = polymorphic_path(social_media_icon, disposition: "attachment").split("?")[0]
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
      @partner_emails = File.exist?(filename) ? File.readlines(filename).map(&:chomp) : []
    end
end
