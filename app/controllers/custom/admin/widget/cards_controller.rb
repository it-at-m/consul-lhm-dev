require_dependency Rails.root.join("app", "controllers", "admin", "widget", "cards_controller").to_s
class Admin::Widget::CardsController < Admin::BaseController

  private

  def card_params
    params.require(:widget_card).permit(
      :link_url, :button_text, :button_url, :alignment, :header, :columns, :card_category,
      translation_params(Widget::Card),
      image_attributes: image_attributes
    )
  end
end
