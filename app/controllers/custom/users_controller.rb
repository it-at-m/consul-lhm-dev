require_dependency Rails.root.join("app", "controllers", "users_controller").to_s

class UsersController < ApplicationController
  skip_authorization_check

  def index
    unless Setting["extended_feature.general.users_overview_page"].present?
      redirect_to root_path, alert: "Diese Funktion ist deaktiviert"
    end

    @users = User.active.order(created_at: :desc).page(params[:page])
  end

  def show
    raise CanCan::AccessDenied if params[:filter] == "follows" && !valid_interests_access?(@user)

    if @user.erased?
      head :not_found
    elsif @user == current_user
      redirect_to account_path
    elsif Setting.new_design_enabled?
      render :show_new
    else
      render :show
    end
  end
end
