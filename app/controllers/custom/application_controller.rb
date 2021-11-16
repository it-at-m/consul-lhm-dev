require_dependency Rails.root.join("app", "controllers", "application_controller").to_s


class ApplicationController < ActionController::Base

  before_action :set_top_level_active_and_archived_projekts_for_menu, :set_default_social_media_images

  private

  def all_selected_tags
    if params[:tags]
      params[:tags].split(",").map { |tag_name| Tag.find_by(name: tag_name) }.compact || []
    else
      []
    end
  end

  def set_top_level_active_and_archived_projekts_for_menu
    @top_level_active_projekts_for_menu = Projekt.top_level.active.visible_in_menu
    @top_level_archived_projekts_for_menu = Projekt.top_level.archived.visible_in_menu
  end

  def set_default_social_media_images
    SiteCustomization::Image.all_images
    social_media_icon_path = SiteCustomization::Image.all.find_by(name: 'social_media_icon').image.url.split('?')[0]
    @social_media_icon_path = social_media_icon_path.include?('missing') ? nil : social_media_icon_path
    social_media_icon_twitter_path = SiteCustomization::Image.all.find_by(name: 'social_media_icon_twitter').image.url.split('?')[0]
    @social_media_icon_twitter_path = social_media_icon_twitter_path.include?('missing') ? nil : social_media_icon_twitter_path
  end

  def set_projets_for_selector
    @projekts = Projekt.top_level
    @resource = @poll || resource_model.new
  end
end
