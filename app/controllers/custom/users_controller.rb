require_dependency Rails.root.join("app", "controllers", "users_controller").to_s

class UsersController < ApplicationController
  skip_authorization_check

  def show
    raise CanCan::AccessDenied if params[:filter] == "follows" && !valid_interests_access?(@user)

    if Setting.new_design_enabled?
      render :show_new
    else
      render :show
    end
  end
end
