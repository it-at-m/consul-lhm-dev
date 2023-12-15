class Admin::UserAuditsController < Admin::BaseController
  def show
    user = User.find(params[:user_id])
    @audit = user.audits.find(params[:id])

    render "admin/audits/show"
  end
end
