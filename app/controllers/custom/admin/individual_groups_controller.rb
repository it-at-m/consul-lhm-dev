class Admin::IndividualGroupsController < Admin::BaseController
  def index
    @individual_groups = IndividualGroup.all
  end

  def show
    @individual_group = IndividualGroup.find(params[:id])
  end

  def new
    @individual_group = IndividualGroup.new
  end

  def create
    @individual_group = IndividualGroup.new(individual_group_params)

    if @individual_group.save
      redirect_to admin_individual_groups_path
    else
      render :new
    end
  end

  def edit
    @individual_group = IndividualGroup.find(params[:id])
  end

  def update
    @individual_group = IndividualGroup.find(params[:id])

    if @individual_group.update(individual_group_params)
      redirect_to admin_individual_groups_path
    else
      render :edit
    end
  end

  def destroy
    @individual_group = IndividualGroup.find(params[:id])
    @individual_group.destroy!

    redirect_to admin_individual_groups_path
  end

  private

    def individual_group_params
      params.require(:individual_group).permit(:name, :kind, :visible)
    end
end
