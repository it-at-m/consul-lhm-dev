require "rails_helper"

describe "Moderation" do
  let(:user) { create(:user) }

  scenario "Access as regular user is not authorized" do
    login_as(user)

    visit root_path

    expect(page).not_to have_link("Menu")
    expect(page).not_to have_link("Moderation")

    visit moderation_root_path

    expect(page).not_to have_current_path(moderation_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  xscenario "Access as valuator is not authorized" do
    create(:valuator, user: user)
    login_as(user)

    visit root_path
    click_link "Menu"

    expect(page).not_to have_link("Moderation")

    visit moderation_root_path

    expect(page).not_to have_current_path(moderation_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  xscenario "Access as manager is not authorized" do
    create(:manager, user: user)
    login_as(user)

    visit root_path
    click_link "Menu"

    expect(page).not_to have_link("Moderation")

    visit moderation_root_path

    expect(page).not_to have_current_path(moderation_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  xscenario "Access as SDG manager is not authorized" do
    create(:sdg_manager, user: user)
    login_as(user)

    visit root_path
    click_link "Menu"

    expect(page).not_to have_link("Moderation")

    visit moderation_root_path

    expect(page).not_to have_current_path(moderation_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  xscenario "Access as poll officer is not authorized" do
    create(:poll_officer, user: user)
    login_as(user)

    visit root_path
    click_link "Menu"

    expect(page).not_to have_link("Moderation")

    visit moderation_root_path

    expect(page).not_to have_current_path(moderation_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  xscenario "Access as a moderator is authorized" do
    create(:moderator, user: user)

    login_as(user)
    visit root_path
    click_link "Menu"
    click_link "Moderation"

    expect(page).to have_current_path(moderation_root_path)
    expect(page).not_to have_content "You do not have permission to access this page"
  end

  xscenario "Access as an administrator is authorized" do
    create(:administrator, user: user)

    login_as(user)
    visit root_path
    click_link "Menu"
    click_link "Moderation"

    expect(page).to have_current_path(moderation_root_path)
    expect(page).not_to have_content "You do not have permission to access this page"
  end

  xscenario "Moderation access links" do
    create(:moderator, user: user)
    login_as(user)

    visit root_path
    click_link "Menu"

    expect(page).to have_link("Moderation")
    expect(page).not_to have_link("Administration")
    expect(page).not_to have_link("Valuation")
  end

  context "Moderation dashboard" do
    before do
      Setting["org_name"] = "OrgName"
    end

    xscenario "Contains correct elements" do
      create(:moderator, user: user)
      login_as(user)

      visit root_path
      click_link "Menu"
      click_link "Moderation"

      expect(page).to have_link("Go back to OrgName")
      expect(page).to have_current_path(moderation_root_path)
      expect(page).to have_css("#moderation_menu")
      expect(page).not_to have_css("#admin_menu")
      expect(page).not_to have_css("#valuation_menu")
    end
  end
end
