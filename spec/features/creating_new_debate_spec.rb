# frozen_string_literal: true

require "rails_helper"

feature "user creates new debate" do
  scenario "successfully", js: true do
    create_projekt_tree
    author = create(:user, :level_three)
    login_as(author)

    visit new_debate_path(locale: :de)

    select_projekt_in_selector
    fill_in "Titel der Diskussion", with: "Titel der Diskussion"
    fill_in_ckeditor "Diskussionenbeitrag", with: "Diskussionenbeitrag"
    check "Ich stimme der Datenschutzbestimmungen und den Allgemeine Nutzungsbedingungen zu"
    click_button "Eine Diskussion starten"

    expect(page).to have_content "Titel der Diskussion"
  end
end
