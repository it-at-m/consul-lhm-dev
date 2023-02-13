# frozen_string_literal: true

require "rails_helper"

feature "user creates new poll" do
  scenario "successfully" do
    create_projekt_tree
    author = create(:administrator).user
    login_as(author)

    visit new_admin_poll_path(locale: :de)

    fill_in "Anfangsdatum", with: 1.month.ago.strftime("%m/%d/%Y")
    fill_in "Enddatum", with: 1.month.from_now.strftime("%m/%d/%Y")
    fill_in "Name", with: "Abstimmung Name"
    fill_in_ckeditor(/\AZusammenfassung\z/, with: "Zusammenfassung Zusammenfassung Zusammenfassung")
    fill_in_ckeditor "Beschreibung", with: "Beschreibung Beschreibung Beschreibung"
    select_projekt_in_selector
    click_button "Abstimmung erstellen"

    expect(page).to have_content "Abstimmung Name"
  end
end
