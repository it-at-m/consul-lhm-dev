require_dependency Rails.root.join("app", "controllers", "welcome_controller").to_s

class WelcomeController < ApplicationController
  include Takeable

  def welcome
    redirect_to root_path
  end

  def index
    @header = Widget::Card.header.first
    @feeds = Widget::Feed.active
    @cards = Widget::Card.body.where(card_category: "")
    @remote_translations = detect_remote_translations(@feeds,
                                                      @recommended_debates,
                                                      @recommended_proposals)

    @active_feeds = @feeds.pluck(:kind)
    @affiliated_geozones = []
    @restricted_geozones = []

    @active_projekts = @active_feeds.include?("active_projekts") ? @feeds.find{ |feed| feed.kind == 'active_projekts' }.active_projekts : []
    @expired_projekts = @active_feeds.include?("expired_projekts") ? @feeds.find{ |feed| feed.kind == 'expired_projekts' }.expired_projekts : []
    @latest_polls = @active_feeds.include?("polls") ? filtered_items(@feeds.find { |feed| feed.kind == 'polls' }) : []

    if @active_feeds.include?("debates") || @active_feeds.include?("proposals") || @active_feeds.include?("investment_proposals")
      @latest_items = @feeds
        .select { |feed| feed.kind == 'proposals' || feed.kind == 'debates' }
        .collect { |feed| filtered_items(feed).to_a }.flatten
        # .collect { |feed| feed.items.to_a }.flatten
        .sort_by(&:created_at).reverse
    else
      @latest_items = []
    end
  end

  private

    def filtered_items(feed)
      @resources = feed.items

      @resources = @resources.joins(projekt_phase: :projekt)
        .merge(Projekt.activated.with_active_feature("general.show_in_sidebar_filter"))
      @resources = @resources.where(projekts: { id: scoped_projekts_ids_for_feed(feed) }).distinct.limit(feed.limit)
    end

    def scoped_projekts_ids_for_feed(feed)
      if feed.kind == "proposals"
        Proposal.scoped_projekt_ids_for_index(current_user)
      elsif feed.kind == "debates"
        Debate.scoped_projekt_ids_for_index(current_user)
      elsif feed.kind == "polls"
        Poll.scoped_projekt_ids_for_index(current_user)
      end
    end
end
