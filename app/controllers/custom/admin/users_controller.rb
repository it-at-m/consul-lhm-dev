require_dependency Rails.root.join("app", "controllers", "admin", "users_controller").to_s

class Admin::UsersController < Admin::BaseController
  def verify
    @user = User.find(params[:id])
    @user.update!(verified_at: Time.current)
  end
end
