require_dependency Rails.root.join("app", "controllers", "polls_controller").to_s

class PollsController < ApplicationController

  include CommentableActions
  include ProjektControllerHelper
  include Takeable

  before_action :set_geo_limitations, only: [:show, :results, :stats]

  helper_method :resource_model, :resource_name
  has_filters %w[all current expired]

  def index
    @resource_name = 'poll'
    @tag_cloud = tag_cloud

    @geozones = Geozone.all
    @selected_geozone_affiliation = params[:geozone_affiliation] || 'all_resources'
    @affiliated_geozones = (params[:affiliated_geozones] || '').split(',').map(&:to_i)
    @selected_geozone_restriction = params[:geozone_restriction] || 'no_restriction'
    @restricted_geozones = (params[:restricted_geozones] || '').split(',').map(&:to_i)

    @resources = Poll.where(show_on_index_page: true)
      .created_by_admin
      .not_budget
      .send(@current_filter)
      .includes(:geozones)

    related_projekt_ids = @resources.joins(projekt_phase: :projekt).pluck("projekts.id").uniq
    related_projekts = Projekt.where(id: related_projekt_ids)

    @scoped_projekt_ids = Poll.scoped_projekt_ids_for_index(current_user)

    @top_level_active_projekts = Projekt.top_level.current.where(id: @scoped_projekt_ids)
    @top_level_archived_projekts = Projekt.top_level.expired.where(id: @scoped_projekt_ids)

    @categories = Tag.category.joins(:taggings)
      .where(taggings: { taggable_type: "Projekt", taggable_id: related_projekt_ids }).order(:name).uniq

    if params[:sdg_goals].present?
      sdg_goal_ids = SDG::Goal.where(code: params[:sdg_goals].split(",")).ids
      @sdg_targets = SDG::Target.where(goal_id: sdg_goal_ids).joins(:relations)
        .where(sdg_relations: { relatable_type: "Projekt", relatable_id: related_projekt_ids })
    end

    @resources = @resources.by_projekt_id(@scoped_projekt_ids)
    @all_resources = @resources

    unless params[:search].present?
      take_by_tag_names(related_projekts)
      take_by_sdgs(related_projekts)
      take_by_geozone_affiliations
      take_by_polls_geozone_restrictions
      take_by_projekts(@scoped_projekt_ids)
    end

    @polls = Kaminari.paginate_array(@resources.sort_for_list).page(params[:page])

    if Setting.new_design_enabled?
      render :index_new
    else
      render :index
    end
  end

  def stats
    @stats = Poll::Stats.new(@poll)

    if Setting.new_design_enabled?
      render :stats_new
    else
      render :stats
    end
  end

  def results
    if Setting.new_design_enabled?
      render :results_new
    else
      render :results
    end
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

  def csv_answers_votes
    authorize! :csv_answers_votes, @poll

    respond_to do |format|
      format.csv do
        send_data CsvServices::PollAnswersVotesExporter.new(@poll).call,
          filename: "poll_#{@poll.id}_answers_votes_#{Time.zone.today.strftime("%d/%m/%Y")}.csv"
      end
    end
  end

  private

    def remove_answers_to_open_questions_with_blank_body
      questions = @poll.questions.each do |question|
        open_question_answers_names = Poll::Question::Answer.where(question: question).select(&:open_answer).pluck(:title)
        open_answers_with_blank_text = Poll::Answer.where(question: question, author: current_user, answer: open_question_answers_names, open_answer_text: nil)
        open_answers_with_blank_text.destroy_all
      end
    end

    # def section(resource_name)
    #   "polls"
    # end

    def resource_model
      Poll
    end
end
