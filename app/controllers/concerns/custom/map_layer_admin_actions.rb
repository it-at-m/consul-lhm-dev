module MapLayerAdminActions
  extend ActiveSupport::Concern

  included do
    before_action :set_map_layer, only: [:edit, :update, :destroy]
    before_action :set_mappable, only: [:new, :create]
    before_action :set_namespace
  end

  def new
    @map_layer = MapLayer.new
    @map_layer.mappable = @mappable
    authorize!(:new, @map_layer) unless current_user.administrator?

    render "custom/admin/map_layers/new"
  end

  def edit
    authorize!(:edit, @map_layer) unless current_user.administrator?

    render "custom/admin/map_layers/edit"
  end

  def create
    @map_layer = MapLayer.new(map_layer_params)
    @map_layer.mappable = @mappable

    authorize!(:create, @map_layer) unless current_user.administrator?

    if @map_layer.save
      redirect_to params[:return_path], notice: t("admin.settings.index.map.flash.update")
    else
      redirect_to params[:return_path], alert: @map_layer.errors.messages.values.flatten.join("; ")
    end
  end

  def update
    authorize!(:update, @map_layer) unless current_user.administrator?

    if @map_layer.update(map_layer_params)
      redirect_to params[:return_path], notice: t("admin.settings.index.map.flash.update")
    else
      redirect_to params[:return_path], alert: @map_layer.errors.messages.values.flatten.join("; ")
    end
  end

  def destroy
    authorize!(:destroy, @map_layer) unless current_user.administrator?

    @map_layer.destroy!
    redirect_to params[:return_path]
  end

  private

    def map_layer_params
      params.require(:map_layer).permit(
        :name, :layer_names, :base, :show_by_default, :provider,
        :attribution, :protocol, :format, :transparent
      )
    end

    def set_map_layer
      @map_layer = MapLayer.find(params[:id])
    end

    def set_mappable
      if params[:mappable_type] && params[:mappable_id]
        @mappable = params[:mappable_type].constantize.find_by(id: params[:mappable_id])
      end
    end

    def set_namespace
      @namespace = params[:controller].split("/").first.to_sym
    end
end
