require_dependency Rails.root.join("app", "controllers", "welcome_controller").to_s

class WelcomeController < ApplicationController
  def welcome
    redirect_to root_path
  end

  def index
    @header = Widget::Card.header.first
    @feeds = Widget::Feed.active
    @cards = Widget::Card.body.where(card_category: "")
    @active_projekt_cards = Widget::Card.body.where(card_category: 'active_projekt')
    @archived_projekt_cards = Widget::Card.body.where(card_category: 'archived_projekt')
    @remote_translations = detect_remote_translations(@feeds,
                                                      @recommended_debates,
                                                      @recommended_proposals)

    @active_feeds = @feeds.pluck(:kind)
    @affiliated_geozones = []
    @restricted_geozones = []

    @latest_polls = @active_feeds.include?("polls") ? @feeds.first.polls : []

    if @active_feeds.include?("debates") || @active_feeds.include?("proposals")
      @latest_items = @feeds.collect{ |feed| feed.items.to_a }.flatten.reject{ |item| item.class.name == "Poll" }.sort_by(&:created_at).reverse
      set_debate_votes(@latest_items.select{|item| item.class.name == 'Debate'})
      set_proposal_votes(@latest_items.select{|item| item.class.name == 'Proposal'})
    else
      @latest_items = []
    end
  end
end
