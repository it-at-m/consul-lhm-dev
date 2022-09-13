class Admin::ProjektManagersController < Admin::BaseController
  load_and_authorize_resource

  def index
    @projekt_managers = @projekt_managers.page(params[:page])
  end

  def search
    @users = User.search(params[:search]).includes(:projekt_manager).page(params[:page])
  end

  def create
    @projekt_manager.user_id = params[:user_id]
    @projekt_manager.save!

    redirect_to admin_projekt_managers_path
  end

  def destroy
    @projekt_manager.destroy!
    redirect_to admin_projekt_managers_path
  end
end
