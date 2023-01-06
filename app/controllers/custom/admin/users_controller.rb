require_dependency Rails.root.join("app", "controllers", "admin", "users_controller").to_s

class Admin::UsersController < Admin::BaseController
  def verify
    @user = User.find(params[:id])
    if @user.verify!
      @verification_result_notice = "Benutzer verifiziert"
      Mailer.manual_verification_confirmation(@user).deliver_later
    else
      @verification_result_notice = "Benutzer konnte nicht verifiziert werden"
    end
  end

  def unverify
    @user = User.find(params[:id])
    @user.update!(verified_at: nil, geozone: nil, unique_stamp: nil)
  end
end
