require_dependency Rails.root.join("app", "controllers", "polls_controller").to_s

class PollsController < ApplicationController

  include CommentableActions
  include ProjektControllerHelper
  include Takeable

  before_action :load_categories, only: [:index]
  before_action :set_geo_limitations, only: [:show, :results, :stats]

  helper_method :resource_model, :resource_name
  has_filters %w[all current]

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

    @scoped_projekt_ids = Poll.scoped_projekt_ids_for_index

    @top_level_active_projekts = Projekt.top_level.current.where(id: @scoped_projekt_ids)
    @top_level_archived_projekts = Projekt.top_level.expired.where(id: @scoped_projekt_ids)

    unless params[:search].present?
      take_by_tag_names
      take_by_sdgs
      take_by_geozone_affiliations
      take_by_polls_geozone_restrictions
      take_by_projekts(@scoped_projekt_ids)
    end

    @polls = Kaminari.paginate_array(@resources.sort_for_list).page(params[:page])
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
