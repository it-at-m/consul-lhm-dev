class Admin::MapLayersController < Admin::BaseController
  before_action :set_map_layer, only: [:edit, :update, :destroy]

  def new
    @map_layer = MapLayer.new
  end

  def edit
  end

  def create
    @map_layer = MapLayer.new(map_layer_params)

    if @map_layer.save
      redirect_to return_path, notice: t("admin.settings.index.map.flash.update")
    else
      redirect_to return_path, alert: @map_layer.errors.messages.values.flatten.join('; ')
    end
  end

  def update
    if @map_layer.update(map_layer_params)
      redirect_to return_path, notice: t("admin.settings.index.map.flash.update")
    else
      redirect_to return_path, alert: @map_layer.errors.messages.values.flatten.join('; ')
    end
  end

  def destroy
    @map_layer.destroy!
    redirect_to return_path
  end

  private

  def map_layer_params
    params.require(:map_layer).permit(:name, :layer_names, :base, :show_by_default, :provider, :attribution, :protocol, :format, :transparent)
  end

  def set_map_layer
    @map_layer = MapLayer.find(params[:id])
  end

  def return_path
    "/#{params[:origin]}#{params[:tab]}"
  end
end
