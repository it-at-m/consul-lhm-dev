class Admin::RegisteredAddressGroupingsController < Admin::BaseController
  load_and_authorize_resource class: RegisteredAddress::Grouping

  def index
    @registered_address_groupings = RegisteredAddress::Grouping.order(created_at: :desc).page(params[:page])
  end

  def edit
  end

  def update
    if @registered_address_grouping.update(grouping_params)
      redirect_to admin_registered_address_groupings_path, notice: t("custom.admin.registered_address_groupings.update.success")
    else
      render :edit
    end
  end

  def destroy
    @registered_address_grouping.destroy!
    redirect_to admin_registered_address_groupings_path, notice: t("custom.admin.registered_address_groupings.destroy.success")
  end

  private

    def grouping_params
      params.require(:registered_address_grouping).permit(:name)
    end
end
