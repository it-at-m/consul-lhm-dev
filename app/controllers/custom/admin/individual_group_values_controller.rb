class Admin::IndividualGroupValuesController < Admin::BaseController
  def index
    @individual_group_values = IndividualGroupValue.where(individual_group_id: params[:individual_group_id])
  end

  def show
    @individual_group_value = IndividualGroupValue.find(params[:id])
    @individual_group = @individual_group_value.individual_group
    @related_users = @individual_group_value.users.page(params[:page])
  end

  def new
    @individual_group_value = IndividualGroupValue.new
  end

  def create
    @individual_group_value = IndividualGroupValue.new(individual_group_value_params)

    if @individual_group_value.save
      redirect_to admin_individual_group_path(@individual_group_value.individual_group)
    else
      render "new"
    end
  end

  def edit
    @individual_group_value = IndividualGroupValue.find(params[:id])
  end

  def update
    @individual_group_value = IndividualGroupValue.find(params[:id])

    if @individual_group_value.update(individual_group_value_params)
      redirect_to admin_individual_group_path(@individual_group_value.individual_group)
    else
      render "edit"
    end
  end

  def destroy
    @individual_group_value = IndividualGroupValue.find(params[:id])
    @individual_group_value.destroy!

    redirect_to admin_individual_group_path(@individual_group_value.individual_group)
  end

  def search_user
    @user = User.find_by(email: params[:search])
    @individual_group_value = IndividualGroupValue.find(params[:id])

    respond_to do |format|
      if @user
        format.js
      else
        format.js { render "user_not_found" }
      end
    end
  end

  def add_user
    @individual_group_value = IndividualGroupValue.find(params[:id])
    @user = User.find(params[:user_id])
    @individual_group_value.users << @user

    redirect_to admin_individual_group_value_path(@individual_group_value.individual_group, @individual_group_value)
  end

  def remove_user
    @individual_group_value = IndividualGroupValue.find(params[:id])
    @user = User.find(params[:user_id])
    @individual_group_value.users.destroy(@user)

    redirect_to admin_individual_group_value_path(@individual_group_value.individual_group, @individual_group_value)
  end

  private

    def individual_group_value_params
      params.require(:individual_group_value).permit(:individual_group_id, :name)
    end
end
