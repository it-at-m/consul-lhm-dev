require_dependency Rails.root.join("app", "controllers", "admin", "homepage_controller").to_s

class Admin::HomepageController < Admin::BaseController
  def show
    load_header
    load_feeds
    load_recommendations
    load_cards
    load_active_projekt_cards
    load_archived_projekt_cards
  end

  private

  def load_active_projekt_cards
    @active_projekt_cards = ::Widget::Card.body.where(card_category: 'active_projekt')
  end

  def load_archived_projekt_cards
    @archived_projekt_cards = ::Widget::Card.body.where(card_category: 'archived_projekt')
  end

  def load_cards
    @cards = ::Widget::Card.body.where(card_category: "")
  end
end
