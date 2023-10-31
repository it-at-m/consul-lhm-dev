require_dependency Rails.root.join("app", "controllers", "communities_controller").to_s

class CommunitiesController < ApplicationController
  def show
    raise ActionController::RoutingError, "Not Found" unless communitable_exists?

    redirect_to root_path if Setting["feature.community"].blank?

    @resource =
      if @community.proposal.present?
        @community.proposal
      elsif @community.investment.present?
        @community.investment
      end

    if Setting.new_design_enabled?
      render :show_new
    else
      render :show
    end
  end
end
