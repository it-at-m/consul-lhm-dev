class Admin::Projekts::MapLayersController < Admin::BaseController
  before_action :set_projekt, only: [:create, :edit, :new, :destroy]
  load_resource :map_layer, only: %i[edit update destroy]

  def new
    @map_layer = @projekt.map_layers.build
    @namespace = params[:namespace]

    if should_authorize_projekt_manager?
      authorize!(:new, @map_layer)
    end
  end

  def edit
    @namespace = params[:namespace]

    if should_authorize_projekt_manager?
      authorize!(:edit, @map_layer)
    end
  end

  def create
    @map_layer = @projekt.map_layers.new(map_layer_params)

    if should_authorize_projekt_manager?
      authorize!(:create, @map_layer)
    end

    if @map_layer.save
      redirect_to redirect_path(params[:projekt_id], params[:tab].to_s),
        notice: t("admin.settings.index.map.flash.update")
    else
      redirect_to redirect_path(params[:projekt_id], params[:tab].to_s),
        alert: @map_layer.errors.messages.values.flatten.join("; ")
    end
  end

  def update
    if should_authorize_projekt_manager?
      authorize!(:update, @map_layer)
    end

    if @map_layer.update(map_layer_params)
      redirect_to redirect_path(params[:projekt_id], params[:tab].to_s),
        notice: t("admin.settings.index.map.flash.update")
    else
      redirect_to redirect_path(params[:projekt_id], params[:tab].to_s),
        alert: @map_layer.errors.messages.values.flatten.join("; ")
    end
  end

  def destroy
    if should_authorize_projekt_manager?
      authorize!(:destroy, @map_layer)
    end

    @map_layer.destroy!
    redirect_to redirect_path(params[:projekt_id], params[:tab].to_s)
  end

  private

    def map_layer_params
      params.require(:map_layer).permit(
        :name, :layer_names, :base, :show_by_default,
        :provider, :attribution, :protocol, :format, :transparent
      )
    end

    def set_projekt
      @projekt = Projekt.find(params[:projekt_id])
    end

    def set_map_layer
      @map_layer = MapLayer.find(params[:id])
    end

    def redirect_path(projekt_id, tab)
      if params[:namespace] == "projekt_management"
        edit_projekt_management_projekt_path(projekt_id) + tab
      else
        edit_admin_projekt_path(projekt_id) + tab
      end
    end
end
