class Admin::DeficiencyReports::OfficersController < Admin::BaseController
  load_and_authorize_resource :officer, class: "DeficiencyReport::Officer", except: [:edit, :show]

  def index
    @officers = DeficiencyReport::Officer.all.page(params[:page])
  end

  def search
    @user = User.find_by(email: params[:search])

    respond_to do |format|
      if @user
        @officer = DeficiencyReport::Officer.find_or_initialize_by(user: @user)
        format.js
      else
        format.js { render 'user_not_found' }
      end
    end
  end

  def create
    @officer.user_id = params[:user_id]
    @officer.save!

    redirect_to admin_deficiency_report_officers_path
  end

  def destroy
    @officer.deficiency_reports.each do |df|
      df.update(officer: nil)
    end
    @officer.destroy!
    redirect_to admin_deficiency_report_officers_path
  end
end
