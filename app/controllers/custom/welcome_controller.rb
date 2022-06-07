require_dependency Rails.root.join("app", "controllers", "welcome_controller").to_s

class WelcomeController < ApplicationController
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
    @latest_polls = @active_feeds.include?("polls") ? @feeds.find{ |feed| feed.kind == 'polls' }.polls : []

    if @active_feeds.include?("debates") || @active_feeds.include?("proposals") || @active_feeds.include?("investment_proposals")
      @latest_items = @feeds
        .select{ |feed| feed.kind == 'proposals' || feed.kind == 'debates' || feed.kind == 'investment_proposals' }
        .collect{ |feed| feed.items.to_a }.flatten
        .sort_by(&:created_at).reverse
      set_debate_votes(@latest_items.select{|item| item.class.name == 'Debate'})
      set_proposal_votes(@latest_items.select{|item| item.class.name == 'Proposal'})
    else
      @latest_items = []
    end
  end
end
