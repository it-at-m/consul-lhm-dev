class Admin::ProjektsController < Admin::BaseController
  before_action :find_projekt, only: [:update, :destroy]
  before_action :load_geozones, only: [:new, :create, :edit, :update]

  def index
    @projekts = Projekt.top_level
    @projekt = Projekt.new
    @projekts_settings = Setting.all.group_by(&:type)['projekts']
  end

  def edit
    @projekt = Projekt.find(params[:id])

    @projekt.build_debate_phase if @projekt.debate_phase.blank?
    @projekt.debate_phase.geozones.build

    @projekt.build_proposal_phase if @projekt.proposal_phase.blank?
    @projekt.proposal_phase.geozones.build
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
    @projekt.debates.unscope(where: :hidden_at).each do |debate|
      debate.update(projekt_id: nil)
    end
    @projekt.proposals.unscope(where: :hidden_at).each do |proposal|
      proposal.update(projekt_id: nil)
    end
    @projekt.polls.unscope(where: :hidden_at).each do |poll|
      poll.update(projekt_id: nil)
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
    params.require(:projekt).permit(:name, :parent_id, :total_duration_active, :total_duration_start, :total_duration_end, :show_in_navigation,
                                    debate_phase_attributes: [:start_date, :end_date, :active, :geozone_restricted, geozone_ids: [] ],
                                    proposal_phase_attributes: [:start_date, :end_date, :active, :geozone_restricted, geozone_ids: [] ])
  end

  def find_projekt
    @projekt = Projekt.find(params[:id])
  end

  def load_geozones
    @geozones = Geozone.all.order(:name)
  end
end
