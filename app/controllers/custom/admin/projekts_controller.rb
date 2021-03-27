class Admin::ProjektsController < Admin::BaseController
  before_action :find_projekt, only: [:update, :destroy]

  def index
    @projekts = Projekt.top_level
    @projekt = Projekt.new
    @projekts_settings = Setting.all.group_by(&:type)['projekts']
  end

  def edit
    @projekt = Projekt.find(params[:id])
  end

  def update
    if @projekt.update_attributes(projekt_params)
      @projekt.update_order
      redirect_to admin_projekts_path
    else
      render action: :edit
    end
  end

  def create
    @projekts = Projekt.top_level.page(params[:page])
    @projekt = Projekt.new(projekt_params)
    
    if @projekt.save
      redirect_to admin_projekts_path
    else
      render :index
    end
  end

  def destroy
    @projekt.children.each do |child|
      child.update(parent: nil)
    end
    @projekt.destroy!
    redirect_to admin_projekts_path
  end

  def order_up
    @projekt = Projekt.find(params[:id])
    @projekt.order_up
    redirect_to admin_projekts_path
  end

  def order_down
    @projekt = Projekt.find(params[:id])
    @projekt.order_down
    redirect_to admin_projekts_path
  end

  private

	def projekt_params
    params.require(:projekt).permit(:name, :parent_id, :total_duration_active, :total_duration_start, :total_duration_end, :debate_phase_active, :debate_phase_start, :debate_phase_end, :proposal_phase_active, :proposal_phase_start, :proposal_phase_end, :show_in_navigation )
	end

	def find_projekt
		@projekt = Projekt.find(params[:id])
	end
end
