require "rails_helper"

describe "User verification" do
  let(:user) { create(:user, first_name: "John", plz: "11111", gender: "male") }

  before do
    Setting["feature.user.skip_verification"] = nil
    login_as(user)
    visit new_residence_path(locale: :de)
  end

  context "when there are no registered addresses" do
    it "submits a verification request if data is present" do
      fill_in_mandatory_fields_for_verification(first_name: "Jane", gender: "weiblich")
      fill_in "Stadt", with: "Bremen"
      fill_in "Postleitzahl", with: "33333"
      fill_in "Straße", with: "Haupstraße"
      fill_in "Hausnummer", with: "123"
      fill_in "Hausnummerergänzung", with: "B"
      click_button "Wohnsitz bestätigen"

      expect(page).to have_current_path(account_path)
      expect(User.count).to eq(1)
      expect(user.reload.first_name).to eq("Jane")
      expect(user.reload.plz.to_s).to eq("33333")
      expect(user.reload.gender).to eq("female")
    end

    it "cannot submit a verification request if data is missing" do
      click_button "Wohnsitz bestätigen"
      expect(page).to have_current_path(new_residence_path)
    end
  end

  context "when there are registered addresses" do
    before do
      FactoryBot.rewind_sequences
      registered_address_street = create(:registered_address_street, name: "Teststraße", plz: "12345")
      registered_address_city = create(:registered_address_city, name: "Teststadt")
      create_list(:registered_address, 3,
                  registered_address_street: registered_address_street,
                  registered_address_city: registered_address_city)
      login_as(user)
      visit new_residence_path(locale: :de)
    end

    context "when user's address is among the existing registered addresses" do
      it "send verification request and links user to registered address" do
        fill_in_mandatory_fields_for_verification
        select "Teststadt", from: "Wohnort"
        select "Teststraße (12345)", from: "Straße"
        select "Teststraße 1a", from: "Adresse"
        click_button "Wohnsitz bestätigen"

        expect(page).to have_current_path(account_path)
        expect(User.count).to eq(1)
        expect(user.reload.registered_address).to eq(RegisteredAddress.first)
        expect(user.reload.street_name).to eq("Teststraße")
        expect(user.reload.street_number).to eq("1")
        expect(user.reload.street_number_extension).to eq("a")
        expect(user.reload.plz.to_s).to eq("12345")
        expect(user.reload.city_name).to eq("Teststadt")
      end
    end
  end
end
