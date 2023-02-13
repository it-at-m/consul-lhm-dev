module CustomExtension
  module SharedActions
    def select_projekt_in_selector
      within "#projekt-selector-fields .projekt-selector .projekt_group" do
        find(".projekt", match: :first).click
      end
    end
  end
end
