require_dependency Rails.root.join("app", "controllers", "pages_controller").to_s

class PagesController < ApplicationController
  include CommentableActions
  include HasOrders
  include CustomHelper
  include ProposalsHelper
  include Takeable
  include RandomSeed

  has_orders %w[most_voted newest oldest], only: :show

  before_action :set_random_seed

  def show
    @custom_page = SiteCustomization::Page.published.find_by(slug: params[:id])

    set_resource_instance
    custom_page_name = Setting.new_design_enabled? ? :custom_page_new : :custom_page

    if @custom_page.present? && @custom_page.projekt.present? && @custom_page.projekt.visible_for?(current_user)
      @projekt = @custom_page.projekt
      @projekt_subscription = ProjektSubscription.find_or_create_by!(projekt: @projekt, user: current_user)

      if @projekt.projekt_phases.active.any?
        @default_projekt_phase = get_default_projekt_phase(params[:projekt_phase_id])
        @projekt_phase = @default_projekt_phase
        params[:projekt_phase_id] = @default_projekt_phase.id
        params[:projekt_id] ||= @projekt.id
        send("set_#{@default_projekt_phase.name}_footer_tab_variables")
      end

      @cards = @custom_page.cards

      render action: custom_page_name

    elsif @custom_page.present? && @custom_page.projekt.present?
      @individual_group_value_names = @custom_page.projekt.individual_group_values.pluck(:name)
      render "custom/pages/forbidden", layout: false

    elsif @custom_page.present?
      @cards = @custom_page.cards
      render action: custom_page_name

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
      format.csv do
        formated_time = Time.current.strftime("%d-%m-%Y-%H-%M-%S")

        if @projekt_phase.name == "debate_phase"
          send_data Debates::CsvExporter.new(@debates.limit(nil)).to_csv,
            filename: "debates1-#{formated_time}.csv"
        elsif @projekt_phase.name == "proposal_phase"
          send_data Proposals::CsvExporter.new(@proposals.limit(nil)).to_csv,
            filename: "proposals1-#{formated_time}.csv"
        end
      end
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

    @resources = @projekt_phase.debates.for_public_render

    if params[:search].present?
      @resources = @resources.search(params[:search])
    else
      take_by_projekt_labels
      take_by_sentiment
    end

    @debates = @resources.perform_sort_by(@current_order, session[:random_seed]).page(params[:page]).per(24)
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

    @resources = @projekt_phase.proposals.for_public_render

    if params[:search].present?
      @resources = @resources.search(params[:search])
    else
      take_by_projekt_labels
      take_by_sentiment
      take_by_my_posts
    end

    @proposals_coordinates = all_proposal_map_locations(@resources)
    @proposals = @resources.perform_sort_by(@current_order, session[:random_seed]).page(params[:page]).per(24)
  end

  def set_voting_phase_footer_tab_variables
    # @valid_filters = %w[all current]
    # @current_filter = @valid_filters.include?(params[:filter]) ? params[:filter] : @valid_filters.first

    @valid_orders = nil

    # @resources = @projekt_phase.polls.for_public_render.send(@current_filter)
    @resources = @projekt_phase.polls.for_public_render.all
    @polls = Kaminari.paginate_array(@resources.sort_for_list).page(params[:page])
  end

  def set_legislation_phase_footer_tab_variables
    @legislation_phase = @projekt_phase
    @current_section = params[:section] || "text"

    @process = @projekt_phase.legislation_process
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

    @heading = @budget.headings.first

    @all_resources = []

    @valid_filters = @budget.investments_filters
    params[:filter] ||= "feasible" if @budget.phase.in?(["selecting", "valuating"])
    params[:filter] ||= "selected" if @budget.phase.in?(["balloting"])
    params[:filter] ||= "all" if @budget.phase.in?(["publishing_prices", "reviewing_ballots"])
    params[:filter] ||= "winners" if @budget.phase == "finished"
    @current_filter = @valid_filters.include?(params[:filter]) ? params[:filter] : "all"

    @valid_orders = %w[random supports ballots ballot_line_weight newest]
    @valid_orders.delete("supports")
    @valid_orders.delete("ballots")
    @valid_orders.delete("ballot_line_weight") unless @budget.phase == "balloting"
    @current_order = @valid_orders.include?(params[:order]) ? params[:order] : @valid_orders.first

    params[:section] ||= "results" if @budget.phase == "finished"

    # con-1036
    if @budget.phase == "publishing_prices" &&
        @projekt_phase.settings.find_by(key: "feature.general.show_results_after_first_vote").value.present?
      @current_filter = "selected"
    end
    # con-1036

    @investments = @budget.investments

    if params[:section] == "results"
      @investments = Budget::Result.new(@budget, @budget.headings.first).investments
    elsif params[:section] == "stats"
      @stats = Budget::Stats.new(@budget)
      @investments = @budget.investments
    else
      query = Budget::Ballot.where(user: current_user, budget: @budget)
      @ballot = @budget.balloting? ? query.first_or_create! : query.first_or_initialize

      @investments = @budget.investments.send(@current_filter)
      @investment_ids = @budget.investments.ids
    end

    if @budget.phase == "finished"
      if @budget.voting_style == "distributed"
        @current_order = "ballot_line_weight"
      elsif @budget.voting_style == "approval" || @budget.voting_style == "knapsack"
        @current_order = "ballots"
      end
    end

    @investments = @investments.perform_sort_by(@current_order, session[:random_seed]).page(params[:page]).per(18)
  end

  def set_milestone_phase_footer_tab_variables
    @current_milestone = @projekt_phase.milestones
                                 .where("publication_date < ?", Time.zone.today)
                                 .order(publication_date: :desc)
                                 .first

    order_newest = @projekt_phase.settings.find_by(key: "feature.general.newest_first").value.present?
    @milestones_publication_date_order = order_newest ? :desc : :asc
  end

  def set_projekt_notification_phase_footer_tab_variables
    @projekt_notifications = @projekt_phase.projekt_notifications
  end

  def set_newsfeed_phase_footer_tab_variables
    @rss_id = @projekt_phase.settings.find_by(key: "option.general.newsfeed_id").value
    @rss_type = @projekt_phase.settings.find_by(key: "option.general.newsfeed_type").value
  end

  def set_event_phase_footer_tab_variables
    @valid_filters = %w[all incoming past]
    @current_filter = @valid_filters.include?(params[:filter]) ? params[:filter] : "all"
    @projekt_events = @projekt_phase.projekt_events.page(params[:page]).send("sort_by_#{@current_filter}")
  end

  def set_question_phase_footer_tab_variables
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

  def set_formular_phase_footer_tab_variables
    @formular = @projekt_phase.formular

    if params[:token].present?
      @recipient = FormularFollowUpLetterRecipient.find_by(subscription_token: params[:token])
      return unless @recipient.present? && @recipient.formular.id == @formular.id

      @formular_fields = @formular.formular_fields.follow_up.each(&:set_custom_attributes)
      @formular_answer = @recipient.formular_answer
    else
      @formular_fields = @formular.formular_fields.primary.each(&:set_custom_attributes)
      @formular_answer = @formular.formular_answers.new
    end

    @formular_answer.answer_errors ||= {}
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
end
