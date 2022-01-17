# frozen_string_literal: true

require 'rails_helper'

feature 'user creates new proposal' do
  scenario 'successfully' do
    projekt = create(:projekt)
    projekt.projekt_settings.find_by(key: 'projekt_feature.main.activate').update(value: true)
    projekt.debate_phase.update(active: true, start_date: 1.month.ago, end_date: 1.month.from_now )
    projekt.proposal_phase.update(active: true, start_date: 1.month.ago, end_date: 1.month.from_now )

    author = create(:user, :level_three)
    login_as(author)

    visit new_proposal_path(locale: :de)
    custom_fill_in_proposal

    click_button "Vorschlag erstellen"

    expect(page).to have_content "Proposal created successfully."
  end
end
