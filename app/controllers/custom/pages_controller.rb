require_dependency Rails.root.join("app", "controllers", "pages_controller").to_s

class PagesController < ApplicationController
  include CommentableActions
  include HasOrders
  include CustomHelper
  include ProposalsHelper

  def show
    @custom_page = SiteCustomization::Page.published.find_by(slug: params[:id])

    set_resource_instance

    if @custom_page.present? && @custom_page.projekt.present?
      @projekt = @custom_page.projekt

      @default_phase_name = default_phase_name

      send("set_#{@default_phase_name}_footer_tab_variables", @projekt)

      scoped_projekt_ids = @projekt.top_parent.all_children_projekts.unshift(@projekt.top_parent).pluck(:id)
      @comments_count = @projekt.comments.count
      @debates_count = Debate.base_selection(scoped_projekt_ids).count
      @proposals_count = Proposal.base_selection(scoped_projekt_ids).count
      @polls_count = Poll.base_selection(scoped_projekt_ids).count

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
    set_comments_footer_tab_variables

    respond_to do |format|
      format.js { render "pages/projekt_footer/footer_tab" }
    end
  end

  def debate_phase_footer_tab
    set_debates_footer_tab_variables

    respond_to do |format|
      format.js { render "pages/projekt_footer/footer_tab" }
    end
  end

  def proposal_phase_footer_tab
    set_proposals_footer_tab_variables

    respond_to do |format|
      format.js { render "pages/projekt_footer/footer_tab" }
    end
  end

  def voting_phase_footer_tab
    set_polls_footer_tab_variables

    respond_to do |format|
      format.js { render "pages/projekt_footer/footer_tab" }
    end
  end

  def budget_phase_footer_tab
    set_budget_footer_tab_variables

    respond_to do |format|
      format.js { render "pages/projekt_footer/footer_tab" }
    end
  end

  def milestone_phase_footer_tab
    set_milestones_footer_tab_variables

    respond_to do |format|
      format.js { render "pages/projekt_footer/footer_tab" }
    end
  end

  def projekt_notifications_footer_tab
    @current_projekt = Projekt.find(params[:id])
    @projekt_notifications = @current_projekt.projekt_notifications

    respond_to do |format|
      format.js { render "pages/projekt_footer/projekt_notifications" }
    end
  end

  def newsfeed_footer_tab
    @current_projekt = Projekt.find(params[:id])
    @rss_id = ProjektSetting.find_by(projekt: @current_projekt, key: "projekt_newsfeed.id").value
    @rss_type = ProjektSetting.find_by(projekt: @current_projekt, key: "projekt_newsfeed.type").value

    respond_to do |format|
      format.js { render "pages/projekt_footer/newsfeed" }
    end
  end

  def extended_sidebar_map
    @current_projekt = Projekt.find(params[:id])

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

  def take_by_projekts
    if params[:filter_projekt_ids].present?
      @filtered_resources = @all_resources.where(projekt_id: params[:filter_projekt_ids]).distinct
    else
      @filtered_resources = @all_resources
    end
  end

  def set_top_level_projekts
    @top_level_active_projekts = Projekt.where( id: @current_projekt.top_parent ).selectable_in_sidebar_current(@current_tab_phase.resources_name)
    @top_level_archived_projekts = Projekt.where( id: @current_projekt.top_parent ).selectable_in_sidebar_expired(@current_tab_phase.resources_name)
  end

  def set_comments_footer_tab_variables(projekt=nil)
    @valid_orders = %w[most_voted newest oldest]
    @current_order = @valid_orders.include?(params[:order]) ? params[:order] : @valid_orders.first

    @current_projekt = projekt || Projekt.find(params[:id])
    @current_tab_phase = @current_projekt.comment_phase

    @commentable = @current_projekt
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
    set_comment_flags(@comment_tree.comments)
  end

  def set_debates_footer_tab_variables(projekt=nil)

    @valid_orders = Debate.debates_orders(current_user)
    @valid_orders.delete('relevance')
    @current_order = @valid_orders.include?(params[:order]) ? params[:order] : @valid_orders.first

    @current_projekt = projekt || Projekt.find(params[:id])
    @current_tab_phase = @current_projekt.debate_phase
    params[:filter_projekt_ids] ||= @current_projekt.all_children_ids.unshift(@current_projekt.id).map(&:to_s)

    @selected_parent_projekt = @current_projekt

    scoped_projekt_ids = @current_projekt.top_parent.all_children_projekts.unshift(@current_projekt.top_parent).pluck(:id)

    @all_resources = Debate.base_selection(scoped_projekt_ids)

    take_by_projekts
    set_top_level_projekts

    set_debate_votes(@all_resources)

    @debates = @filtered_resources.page(params[:page]).send("sort_by_#{@current_order}")
  end

  def set_proposals_footer_tab_variables(projekt=nil)
    @valid_orders = Proposal.proposals_orders(current_user)
    @valid_orders.delete("archival_date")
    @valid_orders.delete('relevance')
    @current_order = @valid_orders.include?(params[:order]) ? params[:order] : @valid_orders.first

    @current_projekt = projekt || Projekt.find(params[:id])
    @current_tab_phase = @current_projekt.proposal_phase
    params[:filter_projekt_ids] ||= @current_projekt.all_children_ids.unshift(@current_projekt.id).map(&:to_s)

    @selected_parent_projekt = @current_projekt

    scoped_projekt_ids = @current_projekt.top_parent.all_children_projekts.unshift(@current_projekt.top_parent).pluck(:id)

    @all_resources = Proposal.base_selection(scoped_projekt_ids)

    take_by_projekts
    set_top_level_projekts

    set_proposal_votes(@filtered_resources)

    @proposals_coordinates = all_proposal_map_locations(@filtered_resources)

    @proposals = @filtered_resources.page(params[:page]).send("sort_by_#{@current_order}")
  end

  def set_polls_footer_tab_variables(projekt=nil)
    @valid_filters = %w[all current]
    @current_filter = @valid_filters.include?(params[:filter]) ? params[:filter] : @valid_filters.first

    @current_projekt = projekt || Projekt.find(params[:id])
    @current_tab_phase = @current_projekt.voting_phase
    @selected_parent_projekt = @current_projekt
    params[:filter_projekt_ids] ||= @current_projekt.all_children_ids.unshift(@current_projekt.id).map(&:to_s)

    scoped_projekt_ids = @current_projekt.top_parent.all_children_projekts.unshift(@current_projekt.top_parent).pluck(:id)

    @all_resources = Poll.base_selection(scoped_projekt_ids).send(@current_filter)

    take_by_projekts
    set_top_level_projekts

    @polls = Kaminari.paginate_array(@filtered_resources.sort_for_list).page(params[:page])
  end

  def set_budget_footer_tab_variables(projekt=nil)
    params[:filter_projekt_id] = projekt&.id || params[:id].to_i
    @current_projekt = Projekt.find(params[:filter_projekt_id])
    @current_tab_phase = @current_projekt.budget_phase

    params[:filter_projekt_id] ||= @current_projekt.id

    @budget = Budget.find_by(projekt_id: params[:filter_projekt_id])

    query = Budget::Ballot.where(user: current_user, budget: @budget)
    @ballot = @budget.balloting? ? query.first_or_create! : query.first_or_initialize

    @investments = @budget.investments
    @investment_ids = @investments.ids

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

  def set_milestones_footer_tab_variables(projekt=nil)
    @current_projekt = projekt || Projekt.find(params[:id])
    @current_tab_phase = @current_projekt.milestone_phase
  end

  def default_phase_name
    default_phase_id = ProjektSetting.find_by(projekt: @projekt, key: 'projekt_custom_feature.default_footer_tab').value
    if default_phase_id.present?
      ProjektPhase.find(default_phase_id).resources_name
    elsif @projekt.projekt_phases.select{ |phase| phase.phase_activated? }.any?
      @projekt.projekt_phases.select{ |phase| phase.phase_activated? }.first.resources_name
    else
      'comments'
    end
  end
end
