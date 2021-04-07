require_dependency Rails.root.join("app", "controllers", "application_controller").to_s


class ApplicationController < ActionController::Base

  private

  def all_selected_tags
    if params[:tags]
      params[:tags].split(",").map { |tag_name| Tag.find_by(name: tag_name) }.compact || []
    else
      []
    end
  end
end
