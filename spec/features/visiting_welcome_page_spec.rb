# frozen_string_literal: true

require 'rails_helper'

feature 'user visits welcome page' do
  scenario 'successfully' do
    visit root_path(locale: :de)

    expect(page).to have_content I18n.t('devise_views.menu.login_items.login')
  end
end
