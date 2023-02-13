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

    if @custom_page.present? && @custom_page.projekt.present?
      @projekt = @custom_page.projekt

      @default_phase_name = default_phase_name(params[:selected_phase_id])

      send("set_#{@default_phase_name}_footer_tab_variables", @projekt)

      @cards = @custom_page.cards

      render action: :custom_page
    elsif @custom_page.present?
      @cards = @custom_page.cards
      render action: :custom_page
    else
      render action: params[:id]
    end
  rescue ActionView::MissingTemplate
    head 404, content_type: "text/html"
  end

  def comment_phase_footer_tab
    set_comment_phase_footer_tab_variables

    respond_to do |format|
      format.js { render "pages/projekt_footer/footer_tab" }
    end
  end

  def debate_phase_footer_tab
    set_debate_phase_footer_tab_variables

    respond_to do |format|
      format.js { render "pages/projekt_footer/footer_tab" }
    end
  end

  def proposal_phase_footer_tab
    set_proposal_phase_footer_tab_variables

    respond_to do |format|
      format.js { render "pages/projekt_footer/footer_tab" }
    end
  end

  def voting_phase_footer_tab
    set_voting_phase_footer_tab_variables

    respond_to do |format|
      format.js { render "pages/projekt_footer/footer_tab" }
    end
  end

  def budget_phase_footer_tab
    set_budget_phase_footer_tab_variables

    respond_to do |format|
      format.js { render "pages/projekt_footer/footer_tab" }
    end
  end

  def milestone_phase_footer_tab
    set_milestone_phase_footer_tab_variables

    respond_to do |format|
      format.js { render "pages/projekt_footer/footer_tab" }
    end
  end

  def projekt_notification_phase_footer_tab
    set_projekt_notification_phase_footer_tab_variables

    respond_to do |format|
      format.js { render "pages/projekt_footer/footer_tab" }
    end
  end

  def newsfeed_phase_footer_tab
    set_newsfeed_phase_footer_tab_variables

    respond_to do |format|
      format.js { render "pages/projekt_footer/footer_tab" }
    end
  end

  def event_phase_footer_tab
    set_event_phase_footer_tab_variables

    respond_to do |format|
      format.js { render "pages/projekt_footer/footer_tab" }
    end
  end

  def legislation_phase_footer_tab
    set_legislation_phase_footer_tab_variables

    respond_to do |format|
      format.js { render "pages/projekt_footer/footer_tab" }
    end
  end

  def question_phase_footer_tab
    set_question_phase_footer_tab_variables

    respond_to do |format|
      format.js { render "pages/projekt_footer/footer_tab" }
    end
  end

  def argument_phase_footer_tab
    set_argument_phase_footer_tab_variables

    respond_to do |format|
      format.js { render "pages/projekt_footer/footer_tab" }
    end
  end

  def livestream_phase_footer_tab
    set_livestream_phase_footer_tab_variables

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

  def resource_model
    SiteCustomization::Page
  end

  def resource_name
    "page"
  end

  def set_top_level_projekts
    @top_level_active_projekts = Projekt.where( id: @current_projekt.top_parent ).current

    @top_level_archived_projekts = Projekt.where( id: @current_projekt.top_parent ).expired
  end

  def set_comment_phase_footer_tab_variables(projekt=nil)
    @valid_orders = %w[most_voted newest oldest]
    @current_order = @valid_orders.include?(params[:order]) ? params[:order] : @valid_orders.first

    @current_projekt = projekt || SiteCustomization::Page.find_by(slug: params[:id]).projekt
    @current_tab_phase = @current_projekt.comment_phase
    params[:current_tab_path] = 'comment_phase_footer_tab'

    @commentable = @current_projekt
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
    set_comment_flags(@comment_tree.comments)
  end

  def set_debate_phase_footer_tab_variables(projekt=nil)
    @current_projekt = projekt || SiteCustomization::Page.find_by(slug: params[:id]).projekt
    @current_tab_phase = @current_projekt.debate_phase

    @valid_orders = Debate.debates_orders(current_user)
    @valid_orders.delete('relevance')

    @current_order = if @valid_orders.include?(params[:order])
                       params[:order]
                     elsif helpers.projekt_feature?(@current_projekt, 'general.set_default_sorting_to_newest') && @valid_orders.include?('created_at')
                       @current_order = 'created_at'
                     else
                       Setting["selectable_setting.debates.default_order"]
                     end

    params[:current_tab_path] = 'debate_phase_footer_tab'
    params[:filter_projekt_ids] ||= @current_projekt.all_children_ids.push(@current_projekt.id).map(&:to_s)
    params[:projekt_label_ids] ||= []

    @selected_parent_projekt = @current_projekt

    set_resources(Debate)
    set_top_level_projekts

    @scoped_projekt_ids = Debate.scoped_projekt_ids_for_footer(@current_projekt)

    unless params[:search].present?
      take_by_my_posts
      # take_by_tag_names
      # take_by_sdgs
      # take_by_geozone_affiliations
      # take_by_geozone_restrictions
      take_by_projekts(@scoped_projekt_ids)
      take_by_projekt_labels if params[:projekt_label_ids].any?
    end

    @debates = @resources.page(params[:page]).send("sort_by_#{@current_order}")
  end

  def set_proposal_phase_footer_tab_variables(projekt=nil)
    @current_projekt = projekt || SiteCustomization::Page.find_by(slug: params[:id]).projekt
    @current_tab_phase = @current_projekt.proposal_phase

    @valid_orders = Proposal.proposals_orders(current_user)
    @valid_orders.delete("archival_date")
    @valid_orders.delete('relevance')

    @current_order = if @valid_orders.include?(params[:order])
                       params[:order]
                     elsif helpers.projekt_feature?(@current_projekt, 'general.set_default_sorting_to_newest') && @valid_orders.include?('created_at')
                       @current_order = 'created_at'
                     else
                       Setting["selectable_setting.proposals.default_order"]
                     end

    params[:current_tab_path] = 'proposal_phase_footer_tab'
    params[:filter_projekt_ids] ||= @current_projekt.all_children_ids.push(@current_projekt.id).map(&:to_s)
    params[:projekt_label_ids] ||= []

    @selected_parent_projekt = @current_projekt

    set_resources(Proposal)
    set_top_level_projekts

    discard_draft
    discard_archived
    load_retired
    load_selected
    load_featured
    remove_archived_from_order_links

    @scoped_projekt_ids = Proposal.scoped_projekt_ids_for_footer(@current_projekt)

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

  def set_voting_phase_footer_tab_variables(projekt=nil)
    @valid_filters = %w[all current]
    @current_filter = @valid_filters.include?(params[:filter]) ? params[:filter] : @valid_filters.first

    @current_projekt = projekt || SiteCustomization::Page.find_by(slug: params[:id]).projekt
    @current_tab_phase = @current_projekt.voting_phase
    params[:current_tab_path] = 'voting_phase_footer_tab'
    params[:filter_projekt_ids] ||= @current_projekt.all_children_ids.push(@current_projekt.id).map(&:to_s)

    @selected_parent_projekt = @current_projekt

    @resources = Poll
      .created_by_admin
      .not_budget
      .send(@current_filter)
      .includes(:geozones)

    set_top_level_projekts

    @scoped_projekt_ids = Poll.scoped_projekt_ids_for_footer(@current_projekt)

    unless params[:search].present?
      # take_by_tag_names
      # take_by_sdgs
      # take_by_geozone_affiliations
      # take_by_polls_geozone_restrictions
      take_by_projekts(@scoped_projekt_ids)
    end

    @polls = Kaminari.paginate_array(@resources.sort_for_list).page(params[:page])
  end

  def set_legislation_phase_footer_tab_variables(projekt=nil)
    @current_section = params[:section] || 'text'

    @current_projekt = projekt || SiteCustomization::Page.find_by(slug: params[:id]).projekt
    @current_tab_phase = @current_projekt.legislation_phase
    params[:current_tab_path] = "legislation_phase_footer_tab"

    @selected_parent_projekt = @current_projekt

    @scoped_projekt_ids = @current_projekt
      .top_parent.all_children_projekts.unshift(@current_projekt.top_parent)
      .pluck(:id)

    @process = @current_projekt.legislation_process
    @draft_versions_list = @process&.draft_versions&.published

    if params[:text_draft_version_id]
      @draft_version = @draft_versions_list.find(params[:text_draft_version_id])
    else
      @draft_version = @draft_versions_list&.last
    end

    if @current_section == 'all_drafts_annotations'
      @annotations = @draft_version.annotations
    end

    if @current_section == 'annotations'
      @annotation = Legislation::Annotation.find(params[:annotation_id])

      @commentable = @annotation

      annotations = [@commentable]

      @valid_orders = %w[most_voted newest oldest]
      @current_order = @valid_orders.include?(params[:order]) ? params[:order] : @valid_orders.first

      @comment_tree = MergedCommentTree.new(annotations, params[:page], @current_order)
      set_comment_flags(@comment_tree.comments)
    end
  end

  def set_budget_phase_footer_tab_variables(projekt = nil)
    params[:filter_projekt_id] = projekt&.id || SiteCustomization::Page.find_by(slug: params[:id]).projekt.id
    @current_projekt = Projekt.find(params[:filter_projekt_id])
    @current_tab_phase = @current_projekt.budget_phase

    return if @current_projekt.budget.blank?

    @valid_filters = @current_projekt.budget.investments_filters
    params[:filter] ||= "feasible" if @current_projekt.budget.phase.in?(["selecting", "valuating"])
    params[:filter] ||= "all" if @current_projekt.budget.phase.in?(["publishing_prices", "balloting", "reviewing_ballots"])
    params[:filter] ||= "winners" if @current_projekt.budget.phase == "finished"
    @current_filter = @valid_filters.include?(params[:filter]) ? params[:filter] : nil
    @all_resources = []

    params[:current_tab_path] = "budget_phase_footer_tab"

    params[:filter_projekt_id] ||= @current_projekt.id

    @budget = Budget.find_by(projekt_id: params[:filter_projekt_id])
    @headings = @budget.headings.sort_by_name
    @heading = @headings.first

    @valid_orders = %w[random supports ballots ballot_line_weight newest]
    @valid_orders.delete("supports")
    @valid_orders.delete("ballots")
    @valid_orders.delete("ballot_line_weight") unless @budget.phase == "balloting"
    @current_order = @valid_orders.include?(params[:order]) ? params[:order] : @valid_orders.first

    params[:section] ||= 'results' if @budget.phase == 'finished'

    # con-1036
    if @budget.phase == 'publishing_prices' &&
        @budget.projekt.present? &&
        @budget.projekt.projekt_settings
          .find_by(key: 'projekt_feature.budgets.show_results_after_first_vote').value.present?
      params[:filter] = 'selected'
      @current_filter = nil
    end
    # con-1036

    if params[:section] == 'results'
      @investments = Budget::Result.new(@budget, @budget.headings.first).investments
    elsif params[:section] == 'stats'
      @stats = Budget::Stats.new(@budget)
      @investments = @budget.investments
    else
      query = Budget::Ballot.where(user: current_user, budget: @budget)
      @ballot = @budget.balloting? ? query.first_or_create! : query.first_or_initialize

      @investments = @budget.investments
      @investments = @investments.send(params[:filter]) if params[:filter]
      @investment_ids = @budget.investments.ids
    end

    if @budget.phase == "finished"
      if @budget.voting_style == "distributed"
        @current_order = "ballot_line_weight"
      elsif @budget.voting_style == "distributed"
        @current_order = "ballots"
      elsif @budget.voting_style == "knapsack"
        @current_order = "ballots"
      end
    end

    @investments = @investments.send("sort_by_#{@current_order}").page(params[:page]).per(20)

    if @budget.present? && @current_projekt.current?
      @top_level_active_projekts = Projekt.where( id: @current_projekt )
      @top_level_archived_projekts = []
    elsif @budget.present? && @current_projekt.expired?
      @top_level_active_projekts = []
      @top_level_archived_projekts = Projekt.where( id: @current_projekt )
    else
      @top_level_active_projekts = []
      @top_level_archived_projekts = []
    end
  end

  def set_milestone_phase_footer_tab_variables(projekt=nil)
    @current_projekt = projekt || SiteCustomization::Page.find_by(slug: params[:id]).projekt
    @current_tab_phase = @current_projekt.milestone_phase
    @current_milestone = @current_projekt.milestones.where("publication_date < ?", Time.zone.today).order(publication_date: :desc).first

    milestone_order_newest = ProjektSetting.find_by(projekt: @current_projekt, key: 'projekt_feature.milestones.newest_first').value.present?
    @milestones_publication_date_order = milestone_order_newest ? :desc : :asc
  end

  def set_projekt_notification_phase_footer_tab_variables(projekt=nil)
    @current_projekt = projekt || SiteCustomization::Page.find_by(slug: params[:id]).projekt
    @current_tab_phase = @current_projekt.projekt_notification_phase
    @projekt_notifications = @current_projekt.projekt_notifications
  end

  def set_newsfeed_phase_footer_tab_variables(projekt=nil)
    @current_projekt = projekt || SiteCustomization::Page.find_by(slug: params[:id]).projekt
    @current_tab_phase = @current_projekt.newsfeed_phase
    @rss_id = ProjektSetting.find_by(projekt: @current_projekt, key: "projekt_newsfeed.id").value
    @rss_type = ProjektSetting.find_by(projekt: @current_projekt, key: "projekt_newsfeed.type").value
  end

  def set_event_phase_footer_tab_variables(projekt=nil)
    @valid_filters = %w[all incoming past]
    @current_filter = @valid_filters.include?(params[:filter]) ? params[:filter] : @valid_filters.first

    params[:current_tab_path] = 'event_phase_footer_tab'

    @current_projekt = projekt || SiteCustomization::Page.find_by(slug: params[:id]).projekt
    @current_tab_phase = @current_projekt.event_phase
    @projekt_events = ProjektEvent.where(projekt_id: @current_projekt).page(params[:page]).send("sort_by_#{@current_filter}")
  end

  def set_question_phase_footer_tab_variables(projekt=nil)
    @current_projekt = projekt || SiteCustomization::Page.find_by(slug: params[:id]).projekt
    @current_tab_phase = @current_projekt.question_phase
    scoped_projekt_ids = @current_projekt.all_children_projekts.unshift(@current_projekt).compact.pluck(:id)
    # @projekt_questions = ProjektQuestion.base_selection(scoped_projekt_ids)

    params[:current_tab_path] = 'question_phase_footer_tab'

    projekt_questions = @current_projekt.questions.root_questions

    if @current_projekt.question_list_enabled?
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

  def set_argument_phase_footer_tab_variables(projekt = nil)
    @current_projekt = projekt || SiteCustomization::Page.find_by(slug: params[:id]).projekt
    @current_tab_phase = @current_projekt.argument_phase

    @projekt_arguments_pro = @current_projekt.projekt_arguments.pro.order(created_at: :desc)
    @projekt_arguments_cons = @current_projekt.projekt_arguments.cons.order(created_at: :desc)
  end

  def set_livestream_phase_footer_tab_variables(projekt = nil)
    @current_projekt = projekt || SiteCustomization::Page.find_by(slug: params[:id]).projekt
    @current_tab_phase = @current_projekt.livestream_phase

    @all_livestreams = @current_projekt.projekt_livestreams.order(created_at: :desc)

    @current_projekt_livestream = @all_livestreams.first
    @other_livestreams = @all_livestreams.select(:id, :title)
  end

  def default_phase_name(default_phase_id)
    default_phase_id ||= ProjektSetting.find_by(projekt: @projekt, key: 'projekt_custom_feature.default_footer_tab').value

    if default_phase_id.present?
      projekt_phase = ProjektPhase.find(default_phase_id)

      if projekt_phase.phase_activated?
        return projekt_phase.name
      end
    end

    if @projekt.projekt_phases.select { |phase| phase.phase_activated? }.any?
      @projekt.projekt_phases.select { |phase| phase.phase_activated? }.first.name
    else
      'comment_phase'
    end
  end

  def set_resources(resource_model)
    @resources = resource_model.all

    @resources = @current_order == "recommendations" && current_user.present? ? @resources.recommendations(current_user) : @resources.for_render
    @resources = @resources.search(@search_terms) if @search_terms.present?
    @resources = @resources.filter_by(@advanced_search_terms)
  end
end
