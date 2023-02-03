# frozen_string_literal: true

require "rails_helper"

feature "user creates new proposal" do
  scenario "successfully", js: true do
    Capybara.current_driver = :selenium_chrome
    setup_proejekt(labels: false)

    author = create(:user, :level_three)
    login_as(author)

    visit new_debate_path(locale: :de)

    fill_in "Titel des Vorschlages", with: "Titel des Vorschlages"
    fill_in "Zusammenfassung Vorschlag", with: "Zusammenfassung Vorschlag..."
    # fill_in_ckeditor "Vorschlagstext", with: "Vorschlagstext..."
    fill_in "Externes Video URL", with: "https://www.youtube.com/watch?v=_51lRi-YJjk"
    check "Ich stimme der Datenschutzbestimmungen und den Allgemeine Nutzungsbedingungen zu"

    click_button "Vorschlag erstellen"

    expect(page).to have_content "Proposal created successfully."
  end
end
