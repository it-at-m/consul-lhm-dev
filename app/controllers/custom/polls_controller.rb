require_dependency Rails.root.join("app", "controllers", "polls_controller").to_s

class PollsController < ApplicationController

  include CommentableActions

  before_action :load_categories, only: [:index]
  before_action :set_geo_limitations, only: [:show]

  helper_method :resource_model, :resource_name

  def index
    @resource_name = 'poll'
    @tag_cloud = tag_cloud

    @filtered_goals = params[:sdg_goals].present? ? params[:sdg_goals].split(',').map{ |code| code.to_i } : nil
    @filtered_target = params[:sdg_targets].present? ? params[:sdg_targets].split(',')[0] : nil

    if params[:projekts]
      @selected_projekts_ids = params[:projekts].split(',')
      selected_projekts = Projekt.where(id: @selected_projekts_ids)
      highest_level_selected_projekts = selected_projekts.sort { |a, b| a.level <=> b.level }.group_by(&:level).first[1]

      if highest_level_selected_projekts.size == 1
        highest_level_selected_projekt = highest_level_selected_projekts.first
      end

      if highest_level_selected_projekt && (@selected_projekts_ids.map(&:to_i) - highest_level_selected_projekt.all_children_ids.push(highest_level_selected_projekt.id) )
        @selected_parent_projekt = highest_level_selected_projekts.first
      end
    end

    @geozones = Geozone.all

    @selected_geozone_affiliation = params[:geozone_affiliation] || 'all_resources'
    @affiliated_geozones = (params[:affiliated_geozones] || '').split(',').map(&:to_i)

    @selected_geozone_restriction = params[:geozone_restriction] || 'no_restriction'
    @restricted_geozones = (params[:restricted_geozones] || '').split(',').map(&:to_i)

    @polls = @polls.created_by_admin.not_budget.send(@current_filter).includes(:geozones)

    unless params[:search].present?
      take_only_by_tag_names
      take_by_projekts
      take_by_sdgs
      take_by_geozone_affiliations
      take_by_geozone_restrictions
    end

    @all_polls = @polls

    @polls = Kaminari.paginate_array(
      @polls.created_by_admin.not_budget.send(@current_filter).includes(:geozones).sort_for_list
    ).page(params[:page])
  end

  def set_geo_limitations
    @selected_geozone_affiliation = params[:geozone_affiliation] || 'all_resources'
    @affiliated_geozones = (params[:affiliated_geozones] || '').split(',').map(&:to_i)

    @selected_geozone_restriction = params[:geozone_restriction] || 'no_restriction'
    @restricted_geozones = (params[:restricted_geozones] || '').split(',').map(&:to_i)
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

  def take_by_geozone_affiliations
    case @selected_geozone_affiliation
    when 'all_resources'
      @polls
    when 'no_affiliation'
      @polls = @polls.joins(:projekt).where( projekts: { geozone_affiliated: 'no_affiliation' } ).distinct
    when 'entire_city'
      @polls = @polls.joins(:projekt).where(projekts: { geozone_affiliated: 'entire_city' } ).distinct
    when 'only_geozones'
      @polls = @polls.joins(:projekt).where(projekts: { geozone_affiliated: 'only_geozones' } ).distinct
      if @affiliated_geozones.present?
        @polls = @polls.joins(:geozone_affiliations).where(geozones: { id: @affiliated_geozones }).distinct
      else
        @polls = @polls.joins(:geozone_affiliations).where.not(geozones: { id: nil }).distinct
      end
    end
  end

  def take_by_geozone_restrictions
    case @selected_geozone_restriction
    when 'no_restriction'
      @polls = @polls
    when 'only_citizens'
      @polls = @polls.left_outer_joins(:geozones_polls).where("polls.geozone_restricted = ? AND geozones_polls.geozone_id IS NULL", true)
    when 'only_geozones'
      if @restricted_geozones.present?
        @polls = @polls.left_outer_joins(:geozones_polls).where("polls.geozone_restricted = ? AND geozones_polls.geozone_id IN (?)", true, @restricted_geozones)
      else
        @polls = @polls.left_outer_joins(:geozones_polls).where("polls.geozone_restricted = ? AND geozones_polls.geozone_id IS NOT NULL", true)
      end
    end
  end
end
