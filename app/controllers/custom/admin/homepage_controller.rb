require_dependency Rails.root.join("app", "controllers", "admin", "homepage_controller").to_s

class Admin::HomepageController < Admin::BaseController
  def show
    load_header
    load_feeds
    load_recommendations
    load_cards
    load_settings
  end

  private

    def load_cards
      @cards = ::Widget::Card.body.where(card_category: "")
    end

    def load_settings
      @settings = Setting.all.group_by(&:type)["welcomepage"]
    end
end
