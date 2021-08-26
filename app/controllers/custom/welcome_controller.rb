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
  end
end
