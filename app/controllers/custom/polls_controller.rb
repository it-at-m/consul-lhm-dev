require_dependency Rails.root.join("app", "controllers", "polls_controller").to_s

class PollsController < ApplicationController

  include CommentableActions
  include ProjektControllerHelper

  before_action :load_categories, only: [:index]
  before_action :set_geo_limitations, only: [:show, :results, :stats]

  helper_method :resource_model, :resource_name
  has_filters %w[all current]

  def index
    @resource_name = 'poll'
    @tag_cloud = tag_cloud

    @filtered_goals = params[:sdg_goals].present? ? params[:sdg_goals].split(',').map{ |code| code.to_i } : nil
    @filtered_target = params[:sdg_targets].present? ? params[:sdg_targets].split(',')[0] : nil

    if params[:projekts]
      @selected_projekts_ids = params[:projekts].split(',').select{ |id| Projekt.find_by(id: id).present? }
      selected_parent_projekt_id = get_highest_unique_parent_projekt_id(@selected_projekts_ids)
      @selected_parent_projekt = Projekt.find_by(id: selected_parent_projekt_id)
    end

    @geozones = Geozone.all

    @selected_geozone_affiliation = params[:geozone_affiliation] || 'all_resources'
    @affiliated_geozones = (params[:affiliated_geozones] || '').split(',').map(&:to_i)

    @selected_geozone_restriction = params[:geozone_restriction] || 'no_restriction'
    @restricted_geozones = (params[:restricted_geozones] || '').split(',').map(&:to_i)

    @polls = @polls.created_by_admin.not_budget.send(@current_filter).includes(:geozones)

    remove_where_projekt_not_active

    unless params[:search].present?
      take_only_by_tag_names
      take_by_projekts
      take_by_sdgs
      take_by_geozone_affiliations
      take_by_geozone_restrictions
    end

    @all_polls = @polls.created_by_admin.not_budget

    @polls = Kaminari.paginate_array(
      @polls.created_by_admin.not_budget.send(@current_filter).includes(:geozones).sort_for_list
    ).page(params[:page])

    @top_level_active_projekts = Projekt.top_level.active.select{ |projekt| projekt.all_children_projekts.unshift(projekt).any? { |p| p.polls.any? } }
    @top_level_archived_projekts = Projekt.top_level.archived.select{ |projekt| projekt.all_children_projekts.unshift(projekt).any? { |p| p.polls.any? } }
  end

  def set_geo_limitations
    @selected_geozone_affiliation = params[:geozone_affiliation] || 'all_resources'
    @affiliated_geozones = (params[:affiliated_geozones] || '').split(',').map(&:to_i)

    @selected_geozone_restriction = params[:geozone_restriction] || 'no_restriction'
    @restricted_geozones = (params[:restricted_geozones] || '').split(',').map(&:to_i)
  end

  def confirm_participation
    remove_answers_to_open_questions_with_blank_body
  end

  private

    def remove_where_projekt_not_active
      active_projekts_ids = Projekt.all.joins(:projekt_settings).where(projekt_settings: { key: 'projekt_feature.main.activate', value: 'active' }).pluck(:id)
      @polls = @polls.joins(:projekt).where(projekts: { id: active_projekts_ids })
    end

    def remove_answers_to_open_questions_with_blank_body
      questions = @poll.questions.each do |question|
        open_question_answers_names = Poll::Question::Answer.where(question: question).select(&:open_answer).pluck(:title)
        open_answers_with_blank_text = Poll::Answer.where(question: question, author: current_user, answer: open_question_answers_names, open_answer_text: nil)
        open_answers_with_blank_text.destroy_all
      end
    end

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
