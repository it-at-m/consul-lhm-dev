require_dependency Rails.root.join("app", "controllers", "welcome_controller").to_s

class WelcomeController < ApplicationController
  include ProjektControllerHelper

  def welcome
    redirect_to root_path
  end

  def index
    @header = Widget::Card.header.first
    @cards = Widget::Card.body.where(card_category: "")
    @feeds = Widget::Feed.active
    @active_feeds = @feeds.pluck(:kind)

    if Setting.new_design_enabled?
      @affiliated_geozones = []
      @restricted_geozones = []

      # TODO
      # @active_projekts = @active_feeds.include?("active_projekts") ? @feeds.find{ |feed| feed.kind == 'active_projekts' }.active_projekts : []

      @all_projekts = Projekt.regular.with_published_custom_page
      @current_active_projekt_filters = Projekt.available_filters(@all_projekts)
      # @current_active_projekt_filters = Projekt.available_filters([])
      @current_projekt_filter = @current_active_projekt_filters.first

      if @current_projekt_filter.present?
        @active_projekts = @all_projekts.send(@current_projekt_filter)
      else
        @active_projekts = @all_projekts
      end

      # TODO: add order
      @active_projekts = @active_projekts.first(3)
      @active_projekts_map_coordinates = all_projekts_map_locations(@active_projekts)

      @proposals = Proposal.where.not(projekt_id: nil).first(3)
      @debates = Debate.where.not(projekt_id: nil).first(3)
      @polls = Poll.where.not(projekt_id: nil).first(3)
      @deficiency_reports = DeficiencyReport.first(3)
      @budgets = Budget::Investment.all.first(3)

      @expired_projekts = @active_feeds.include?("expired_projekts") ? @feeds.find{ |feed| feed.kind == 'expired_projekts' }.expired_projekts : []
      @latest_polls = @active_feeds.include?("polls") ? @feeds.find{ |feed| feed.kind == 'polls' }.polls : []

      if @active_feeds.include?("debates") || @active_feeds.include?("proposals") || @active_feeds.include?("investment_proposals")
        @latest_items = @feeds
          .select{ |feed| feed.kind == 'proposals' || feed.kind == 'debates' || feed.kind == 'investment_proposals' }
          .collect{ |feed| feed.items.to_a }.flatten
          .sort_by(&:created_at).reverse
      else
        @latest_items = []
      end

      render :index
    else
      set_old_design_data

      render :index_old
    end
  end

  private

  def set_old_design_data
    @remote_translations = detect_remote_translations(@feeds,
                                                      @recommended_debates,
                                                      @recommended_proposals)

    @affiliated_geozones = []
    @restricted_geozones = []

    @active_projekts = @active_feeds.include?("active_projekts") ? @feeds.find{ |feed| feed.kind == 'active_projekts' }.active_projekts : []
    @expired_projekts = @active_feeds.include?("expired_projekts") ? @feeds.find{ |feed| feed.kind == 'expired_projekts' }.expired_projekts : []
    @latest_polls = @active_feeds.include?("polls") ? @feeds.find{ |feed| feed.kind == 'polls' }.polls : []

    if @active_feeds.include?("debates") || @active_feeds.include?("proposals") || @active_feeds.include?("investment_proposals")
      @latest_items = @feeds
        .select{ |feed| feed.kind == 'proposals' || feed.kind == 'debates' || feed.kind == 'investment_proposals' }
        .collect{ |feed| feed.items.to_a }.flatten
        .sort_by(&:created_at).reverse
    else
      @latest_items = []
    end
  end
end
