require_dependency Rails.root.join("app", "controllers", "pages_controller").to_s

class PagesController < ApplicationController
  include CommentableActions
  include HasOrders
  include CustomHelper

  has_orders %w[most_voted newest oldest], only: :show

  def show
    @custom_page = SiteCustomization::Page.published.find_by(slug: params[:id])

    @commentable = @custom_page
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
    set_comment_flags(@comment_tree.comments)
    set_resource_instance


    if @custom_page.present? && @custom_page.projekt.present?
      @proposals_coordinates = all_projekt_proposals_map_locations(@custom_page.projekt)

      @most_active_proposals = Proposal.published.not_archived.where(projekt: @custom_page.projekt).sort_by_hot_score.limit(3)
      set_proposal_votes(@most_active_proposals)

      @most_active_debates = Debate.where(projekt: @custom_page.projekt).sort_by_hot_score.limit(3)
      set_debate_votes(@most_active_debates)

      @latest_polls = Poll.where(projekt: @custom_page.projekt.all_children_ids.push(@custom_page.projekt.id)).current.order(created_at: :asc).limit(3)

      @cards = @custom_page.cards

      @geozones = Geozone.all

      @selected_geozone_affiliation = params[:geozone_affiliation] || 'all_resources'
      @affiliated_geozones = (params[:affiliated_geozones] || '').split(',').map(&:to_i)

      @selected_geozone_restriction = params[:geozone_restriction] || 'no_restriction'
      @restricted_geozones = (params[:restricted_geozones] || '').split(',').map(&:to_i)

      @rss_id = ProjektSetting.find_by(projekt: @custom_page.projekt, key: "projekt_newsfeed.id").value
      @rss_type = ProjektSetting.find_by(projekt: @custom_page.projekt, key: "projekt_newsfeed.type").value

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

  private

  def resource_model
    SiteCustomization::Page
  end

  def resource_name
    "page"
  end

end
