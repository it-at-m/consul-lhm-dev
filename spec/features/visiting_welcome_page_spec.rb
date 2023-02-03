# frozen_string_literal: true

require "rails_helper"

feature "user visits welcome page", js: true do
  scenario "successfully" do
    Capybara.current_driver = :selenium_chrome

    visit_home_page

    expect(page).to have_selector "h2", text: "ÖFFENTLICHKEITSBETEILIGUNG\nIN DER STADT CONSUL"
  end
end
