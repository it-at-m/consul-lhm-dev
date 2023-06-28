require_dependency Rails.root.join("app", "controllers", "pages_controller").to_s

class PagesController < ApplicationController
  include CommentableActions
  include HasOrders
  include CustomHelper
  include ProposalsHelper
  include Takeable

  has_orders %w[most_voted newest oldest], only: :show

  def show
    @custom_page = SiteCustomization::Page.published.find_by(slug: params[:id])

    set_resource_instance

    if @custom_page.present? && @custom_page.projekt.present? && @custom_page.projekt.visible_for?(current_user)
      @projekt = @custom_page.projekt
      @projekt_subscription = ProjektSubscription.find_or_create_by!(projekt: @projekt, user: current_user)

      if @projekt.projekt_phases.active.any?
        @default_projekt_phase = get_default_projekt_phase(params[:selected_phase_id])
        @projekt_phase = @default_projekt_phase
        params[:projekt_phase_id] = @default_projekt_phase.id
        params[:projekt_id] ||= @projekt.id
        send("set_#{@default_projekt_phase.name}_footer_tab_variables")
      end

      @cards = @custom_page.cards

      render action: :custom_page

    elsif @custom_page.present? && @custom_page.projekt.present?
      @individual_group_value_names = @custom_page.projekt.individual_group_values.pluck(:name)
      render "custom/pages/forbidden", layout: false

    elsif @custom_page.present?
      @cards = @custom_page.cards
      render action: :custom_page

    else
      render action: params[:id]
    end
  rescue ActionView::MissingTemplate
    head :not_found, content_type: "text/html"
  end

  def projekt_phase_footer_tab
    @projekt_phase = ProjektPhase.find(params[:projekt_phase_id])
    @projekt = @projekt_phase.projekt

    params[:projekt_phase_id] = @projekt_phase.id
    params[:projekt_id] ||= @projekt.id

    send("set_#{@projekt_phase.name}_footer_tab_variables")

    respond_to do |format|
      format.js { render "pages/projekt_footer/footer_tab" }
    end
  end

  def extended_sidebar_map
    @current_projekt = SiteCustomization::Page.find_by(slug: params[:id]).projekt

    respond_to do |format|
      format.js { render "pages/sidebar/extended_map" }
    end
  end

  private

  def set_comment_phase_footer_tab_variables
    @valid_orders = %w[most_voted newest oldest]
    @current_order = @valid_orders.include?(params[:order]) ? params[:order] : @valid_orders.first

    @commentable = @projekt_phase
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
    set_comment_flags(@comment_tree.comments)
  end

  def set_debate_phase_footer_tab_variables
    @valid_orders = Debate.debates_orders(current_user)
    @valid_orders.delete("relevance")

    @current_order = if @valid_orders.include?(params[:order])
                       params[:order]
                     elsif helpers.projekt_feature?(@projekt, "general.set_default_sorting_to_newest") && @valid_orders.include?("created_at")
                       @current_order = "created_at"
                     else
                       Setting["selectable_setting.debates.default_order"]
                     end

    params[:filter_projekt_ids] ||= @projekt.all_children_ids.push(@projekt.id).map(&:to_s)
    params[:projekt_label_ids] ||= []

    @selected_parent_projekt = @projekt

    set_resources(Debate)
    set_top_level_projekts

    @scoped_projekt_phase_ids = Debate.scoped_projekt_phase_ids_for_footer(@projekt_phase)

    unless params[:search].present?
      take_by_my_posts
      # take_by_tag_names
      # take_by_sdgs
      # take_by_geozone_affiliations
      # take_by_geozone_restrictions
      take_by_projekt_phases(@scoped_projekt_phase_ids)
      take_by_projekt_labels if params[:projekt_label_ids].any?
    end

    @debates = @resources.page(params[:page]).send("sort_by_#{@current_order}")
  end

  def set_proposal_phase_footer_tab_variables
    @valid_orders = Proposal.proposals_orders(current_user)
    @valid_orders.delete("archival_date")
    @valid_orders.delete("relevance")

    @current_order = if @valid_orders.include?(params[:order])
                       params[:order]
                     elsif helpers.projekt_feature?(@projekt, "general.set_default_sorting_to_newest") && @valid_orders.include?("created_at")
                       @current_order = "created_at"
                     else
                       Setting["selectable_setting.proposals.default_order"]
                     end

    params[:filter_projekt_ids] ||= @projekt.all_children_ids.push(@projekt.id).map(&:to_s)
    params[:projekt_label_ids] ||= []

    @selected_parent_projekt = @projekt

    set_resources(Proposal)
    set_top_level_projekts

    discard_draft
    discard_archived
    load_retired
    load_selected
    load_featured
    remove_archived_from_order_links

    @scoped_projekt_ids = Proposal.scoped_projekt_ids_for_footer(@projekt)

    unless params[:search].present?
      take_by_my_posts
      # take_by_tag_names
      # take_by_sdgs
      # take_by_geozone_affiliations
      # take_by_geozone_restrictions
      take_by_projekts(@scoped_projekt_ids)
      take_by_projekt_labels if params[:projekt_label_ids].any?
    end

    @proposals_coordinates = all_proposal_map_locations(@resources)

    @proposals = @resources.page(params[:page]).send("sort_by_#{@current_order}")
  end

  def set_voting_phase_footer_tab_variables
    @valid_filters = %w[all current]
    @current_filter = @valid_filters.include?(params[:filter]) ? params[:filter] : @valid_filters.first

    # params[:filter_projekt_ids] ||= @current_projekt.all_children_ids.push(@current_projekt.id).map(&:to_s)
    @selected_parent_projekt = @projekt

    @resources = Poll
      .created_by_admin
      .not_budget
      .send(@current_filter)
      .includes(:geozones)

    set_top_level_projekts

    @scoped_projekt_ids = Poll.scoped_projekt_ids_for_footer(@projekt)

    unless params[:search].present?
      # take_by_tag_names
      # take_by_sdgs
      # take_by_geozone_affiliations
      # take_by_polls_geozone_restrictions
      take_by_projekts(@scoped_projekt_ids)
    end

    @polls = Kaminari.paginate_array(@resources.sort_for_list).page(params[:page])
  end

  def set_legislation_phase_footer_tab_variables
    @legislation_phase = @projekt_phase
    @current_section = params[:section] || "text"

    @selected_parent_projekt = @projekt

    @scoped_projekt_ids = @projekt.top_parent.all_children_projekts.unshift(@projekt.top_parent).pluck(:id)

    @process = @projekt.legislation_process
    @draft_versions_list = @process&.draft_versions&.published

    if params[:text_draft_version_id]
      @draft_version = @draft_versions_list.find(params[:text_draft_version_id])
    else
      @draft_version = @draft_versions_list&.last
    end

    if @current_section == "all_drafts_annotations"
      @annotations = @draft_version.annotations
    end

    if @current_section == "annotations"
      @annotation = Legislation::Annotation.find(params[:annotation_id])

      @commentable = @annotation

      annotations = [@commentable]

      @valid_orders = %w[most_voted newest oldest]
      @current_order = @valid_orders.include?(params[:order]) ? params[:order] : @valid_orders.first

      @comment_tree = MergedCommentTree.new(annotations, params[:page], @current_order)
      set_comment_flags(@comment_tree.comments)
    end
  end

  def set_budget_phase_footer_tab_variables
    @budget = @projekt_phase.budget
    return if @budget.blank?

    @all_resources = []

    @valid_filters = @budget.investments_filters
    params[:filter] ||= "feasible" if @budget.phase.in?(["selecting", "valuating"])
    params[:filter] ||= "all" if @budget.phase.in?(["publishing_prices", "balloting", "reviewing_ballots"])
    params[:filter] ||= "winners" if @budget.phase == "finished"
    @current_filter = @valid_filters.include?(params[:filter]) ? params[:filter] : nil

    @valid_orders = %w[random supports ballots ballot_line_weight newest]
    @valid_orders.delete("supports")
    @valid_orders.delete("ballots")
    @valid_orders.delete("ballot_line_weight") unless @budget.phase == "balloting"
    @current_order = @valid_orders.include?(params[:order]) ? params[:order] : @valid_orders.first

    params[:section] ||= "results" if @budget.phase == "finished"

    # con-1036
    if @budget.phase == "publishing_prices" &&
        @projekt.projekt_settings
          .find_by(key: "projekt_feature.budgets.show_results_after_first_vote").value.present?
      params[:filter] = "selected"
      @current_filter = nil
    end
    # con-1036

    if params[:section] == "results"
      @investments = Budget::Result.new(@budget, @budget.headings.first).investments
    elsif params[:section] == "stats"
      @stats = Budget::Stats.new(@budget)
      @investments = @budget.investments
    else
      query = Budget::Ballot.where(user: current_user, budget: @budget)
      @ballot = @budget.balloting? ? query.first_or_create! : query.first_or_initialize

      @investments = @budget.investments.send(params[:filter]) if params[:filter]
      @investment_ids = @budget.investments.ids
    end

    if @budget.phase == "finished"
      if @budget.voting_style == "distributed"
        @current_order = "ballot_line_weight"
      elsif @budget.voting_style == "approval" || @budget.voting_style == "knapsack"
        @current_order = "ballots"
      end
    end

    @investments = @investments.send("sort_by_#{@current_order}").page(params[:page]).per(20)

    if @budget.present? && @projekt.current?
      @top_level_active_projekts = Projekt.where(id: @projekt)
      @top_level_archived_projekts = []
    elsif budget.present? && projekt.expired?
      @top_level_active_projekts = []
      @top_level_archived_projekts = Projekt.where(id: @projekt)
    else
      @top_level_active_projekts = []
      @top_level_archived_projekts = []
    end
  end

  def set_milestone_phase_footer_tab_variables
    @current_milestone = @projekt.milestones
                                 .where("publication_date < ?", Time.zone.today)
                                 .order(publication_date: :desc)
                                 .first

    order_newest = ProjektSetting.find_by(projekt: @projekt, key: "projekt_feature.milestones.newest_first").value.present?
    @milestones_publication_date_order = order_newest ? :desc : :asc
  end

  def set_projekt_notification_phase_footer_tab_variables
    @projekt_notifications = @projekt_phase.projekt_notifications
  end

  def set_newsfeed_phase_footer_tab_variables
    @rss_id = ProjektSetting.find_by(projekt: @projekt, key: "projekt_newsfeed.id").value
    @rss_type = ProjektSetting.find_by(projekt: @projekt, key: "projekt_newsfeed.type").value
  end

  def set_event_phase_footer_tab_variables
    @valid_filters = %w[all incoming past]
    @current_filter = @valid_filters.include?(params[:filter]) ? params[:filter] : @valid_filters.first
    @projekt_events = @projekt_phase.projekt_events.page(params[:page]).send("sort_by_#{@current_filter}")
  end

  def set_question_phase_footer_tab_variables
    # scoped_projekt_ids = @current_projekt.all_children_projekts.unshift(@current_projekt).compact.pluck(:id)
    # @projekt_questions = ProjektQuestion.base_selection(scoped_projekt_ids)

    projekt_questions = @projekt_phase.questions.root_questions

    if @projekt_phase.question_list_enabled?
      @projekt_questions = projekt_questions
    else
      @projekt_question = projekt_questions.first
      @commentable = @projekt_question

      @valid_orders = %w[most_voted newest oldest]
      @current_order = @valid_orders.include?(params[:order]) ? params[:order] : @valid_orders.first

      @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)

      if @commentable.present?
        set_comment_flags(@comment_tree.comments)
      end

      @projekt_question_answer = @projekt_question&.answer_for_user(current_user) || ProjektQuestionAnswer.new
    end
  end

  def set_argument_phase_footer_tab_variables
    @projekt_arguments_pro = @projekt_phase.projekt_arguments.pro.order(created_at: :desc)
    @projekt_arguments_cons = @projekt_phase.projekt_arguments.cons.order(created_at: :desc)
  end

  def set_livestream_phase_footer_tab_variables
    @all_livestreams = @projekt_phase.projekt_livestreams.order(created_at: :desc)
    @current_projekt_livestream = @all_livestreams.first
    @other_livestreams = @all_livestreams.select(:id, :title)
  end

  def get_default_projekt_phase(default_phase_id = nil)
    default_phase_id ||= ProjektSetting.find_by(projekt: @projekt, key: "projekt_custom_feature.default_footer_tab").value
    @default_projekt_phase = ProjektPhase.find_by(id: default_phase_id) || @projekt.projekt_phases.active.first
  end

  def set_resources(resource_model)
    @resources = resource_model.all

    @resources = @current_order == "recommendations" && current_user.present? ? @resources.recommendations(current_user) : @resources.for_render
    @resources = @resources.search(@search_terms) if @search_terms.present?
    @resources = @resources.filter_by(@advanced_search_terms)
  end

  def resource_model
    SiteCustomization::Page
  end

  def resource_name
    "page"
  end

  def set_top_level_projekts
    @top_level_active_projekts = Projekt.where(id: @projekt.top_parent).current
    @top_level_archived_projekts = Projekt.where(id: @projekt.top_parent).expired
  end
end
