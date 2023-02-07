# frozen_string_literal: true

require "rails_helper"

feature "user creates new proposal" do
  scenario "successfully" do
    create_projekt_tree
    author = create(:user, :level_three)
    login_as(author)

    visit new_proposal_path(locale: :de)

    select_projekt_in_selector
    fill_in "Titel des Vorschlages", with: "Titel des Vorschlages"
    fill_in_ckeditor "Vorschlagstext", with: "Vorschlagstext"
    check "Ich stimme der Datenschutzbestimmungen und den Allgemeine Nutzungsbedingungen zu"
    click_button "Vorschlag jetzt veröffentlichen"

    expect(page).to have_content "Titel des Vorschlages"
  end
end
