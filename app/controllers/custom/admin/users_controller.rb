require_dependency Rails.root.join("app", "controllers", "admin", "users_controller").to_s

class Admin::UsersController < Admin::BaseController
  def verify
    @user = User.find(params[:id])
    @user.take_votes_from_erased_user
    @user.update!(verified_at: Time.current)

    Mailer.manual_verification_confirmation(@user).deliver_later
  end

  def unverify
    @user = User.find(params[:id])
    @user.take_votes_from_erased_user
    @user.update!(verified_at: nil)
  end
end
