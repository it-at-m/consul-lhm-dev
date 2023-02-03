module CustomExtension
  module SharedActions
    def visit_home_page
      I18n.with_locale(:de) do
        visit root_path(locale: :de)
        click_on "Alle akzeptieren"
      end
    end

    def select_projekt_in_selector
      within "#projekt-selector-fields .projekt-selector .projekt_group" do
        find(".projekt", match: :first).click
      end
    end
  end
end
