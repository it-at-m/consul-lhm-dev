class ProjektManagement::SiteCustomization::CardsController < ProjektManagement::BaseController
  include Admin::Widget::CardsActions

  load_and_authorize_resource :page, class: "::SiteCustomization::Page"
  load_and_authorize_resource :card, through: :page, class: "::Widget::Card", except: :index

  helper_method :index_path

  def index
    @cards = @page.cards
    authorize! :index, Widget::Card

    render "admin/site_customization/cards/index"
  end

  private

    def index_path
      projekt_management_site_customization_page_widget_cards_path(@page)
    end
end
