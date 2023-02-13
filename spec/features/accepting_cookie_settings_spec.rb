# frozen_string_literal: true

require "rails_helper"

feature "accepting cookie settings" do
  scenario "successfully", js: true do
    page.driver.browser.manage.delete_cookie("klaro")
    visit root_path(locale: :de)
    expect(page).to have_selector "h2", text: "ÖFFENTLICHKEITSBETEILIGUNG\nIN DER STADT CONSUL"

    click_button "Alle akzeptieren"
    expect(page.driver.browser.manage.cookie_named("klaro")[:value]).to eq("%7B%22system%22%3Atrue%7D")
  end
end
