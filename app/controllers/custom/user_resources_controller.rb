# frozen_string_literal: true

class UserResourcesController < ApplicationController
  skip_authorization_check

  def index
    @user = User.find(params[:id])

    @resources =
      if params[:resources_type] == "proposals"
        @user.proposals
      elsif params[:resources_type] == "debates"
        @user.debates
      end

    @resources = @resources.order(created_at: :desc)
  end
end
