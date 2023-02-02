# frozen_string_literal: true

require "rails_helper"

feature "user visits welcome page", js: true do
  scenario "successfully" do
    Capybara.current_driver = :selenium_chrome

    I18n.with_locale(:de) do
      visit root_path(locale: :de)
      expect(page).to have_selector "h2", text: "ÖFFENTLICHKEITSBETEILIGUNG\nIN DER STADT CONSUL"
    end
  end
end
