require_dependency Rails.root.join("app", "controllers", "polls_controller").to_s

class PollsController < ApplicationController

  include CommentableActions

  before_action :load_categories, only: [:index]

  helper_method :resource_model, :resource_name

  def index
    @resource_name = 'poll'
    @tag_cloud = tag_cloud

    @filtered_goals = params[:sdg_goals].present? ? params[:sdg_goals].split(',').map{ |code| code.to_i } : nil
    @filtered_target = params[:sdg_targets].present? ? params[:sdg_targets].split(',')[0] : nil

    @geozones = Geozone.all
    @selected_geozone_restriction = params[:geozone_restriction] || ''
    @selected_geozones = (params[:geozones] || '').split(',').map(&:to_i)

    @polls = @polls.created_by_admin.not_budget.send(@current_filter).includes(:geozones)
    take_only_by_tag_names
    take_by_projekts
    take_by_sdgs
    take_by_geozones

    @all_polls = @polls

    @polls = Kaminari.paginate_array(
      @polls.created_by_admin.not_budget.send(@current_filter).includes(:geozones).sort_for_list
    ).page(params[:page])
  end

  private

    def section(resource_name)
      "polls"
    end

    def resource_model
      Poll
    end

  def take_only_by_tag_names
    if params[:tags].present?
      @polls = @polls.tagged_with(params[:tags].split(","), all: true, any: :true)
    end
  end

  def take_by_projekts
    if params[:projekts].present?
      @polls = @polls.where(projekt_id: params[:projekts].split(',') ).distinct
    end
  end

  def take_by_sdgs
    if params[:sdg_targets].present?
      @polls = @polls.joins(:sdg_global_targets).where(sdg_targets: { code: params[:sdg_targets].split(',')[0] }).distinct
      return
    end

    if params[:sdg_goals].present?
      @polls = @polls.joins(:sdg_goals).where(sdg_goals: { code: params[:sdg_goals].split(',') }).distinct
    end
  end

  def take_by_geozones
    case @selected_geozone_restriction
    when 'all_resources'
      @polls
    when 'only_citizens'
      if @selected_geozones.blank?
        @polls = @polls.where( geozone_restricted: true )
      else
        @polls = @polls.where( geozone_restricted: true ).joins(:geozones).where( geozones: { id: @selected_geozones } )
      end
    end
  end
end
