require_dependency Rails.root.join("app", "controllers", "welcome_controller").to_s

class WelcomeController < ApplicationController
  include ProjektControllerHelper

  def welcome
    redirect_to root_path
  end

  def index
    @affiliated_geozones = []
    @restricted_geozones = []

    @header = Widget::Card.header.first
    @cards = Widget::Card.body.where(card_category: "")
    @feeds = Widget::Feed.active
    @active_feeds = @feeds.pluck(:kind)

    @active_projekts =
      if @active_feeds.include?("active_projekts")
        @feeds.find { |feed| feed.kind == "active_projekts" }.active_projekts
      else
        []
      end

    @expired_projekts =
      if @active_feeds.include?("expired_projekts")
        @feeds.find { |feed| feed.kind == "expired_projekts" }.expired_projekts
      else
        []
      end

    @latest_polls =
      if @active_feeds.include?("polls")
        @feeds.find { |feed| feed.kind == "polls" }.polls
      else
        []
      end

    if @active_feeds.include?("debates") || @active_feeds.include?("proposals") || @active_feeds.include?("investment_proposals")
      @latest_items =
        @feeds
          .select { |feed| feed.kind == "proposals" || feed.kind == "debates" || feed.kind == 'investment_proposals' }
          .map { |feed| feed.items.to_a }.flatten
          .sort_by(&:created_at).reverse
    else
      @latest_items = []
    end

    if Setting.new_design_enabled?
      @all_projekts = Projekt.regular.with_published_custom_page
      @current_active_projekt_filters = Projekt.available_filters(@all_projekts)
      # @current_active_projekt_filters = Projekt.available_filters([])
      @current_projekt_filter = @current_active_projekt_filters.first

      if @current_projekt_filter.present?
        @active_projekts = @all_projekts.send(@current_projekt_filter)
      else
        @active_projekts = @all_projekts
      end

      @active_projekts_map_coordinates = all_projekts_map_locations(@active_projekts.map(&:id))

      if @active_feeds.include?("debates") || @active_feeds.include?("proposals") || @active_feeds.include?("investment_proposals")
        @latest_items =
          @feeds
            .select{ |feed| feed.kind == 'proposals' || feed.kind == 'debates' || feed.kind == 'investment_proposals' }
            .collect{ |feed| feed.items.to_a }.flatten
            .sort_by(&:created_at).reverse
      else
        @latest_items = []
      end

      render :index_new
    else
      @remote_translations =
        detect_remote_translations(
          @feeds,
          @recommended_debates,
          @recommended_proposals
        )

      render :index
    end
  end
end
