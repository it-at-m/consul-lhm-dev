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

      expect(user.reload).to have_attributes(
        first_name: "Jane",
        plz: 33333,
        gender: "female",
        unique_stamp: nil,
        geozone: nil
      )
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
        fill_in_mandatory_fields_for_verification(first_name: " John ", last_name: "Doe")
        select "Teststadt", from: "Wohnort"
        select "Teststraße (12345)", from: "Straße"
        select "Teststraße 1a", from: "Adresse"
        click_button "Wohnsitz bestätigen"

        expect(page).to have_current_path(account_path)
        expect(User.count).to eq(1)
        expect(user.reload).to have_attributes(
          registered_address: RegisteredAddress.first,
          street_name: "Teststraße",
          street_number: "1",
          street_number_extension: "a",
          plz: 12345,
          city_name: "Teststadt",
          unique_stamp: nil,
          geozone_id: nil
        )
      end
    end

    context "when user's address is not among the existing registered addresses" do
      it "send verification request and does not link user to registered address" do
        fill_in_mandatory_fields_for_verification(first_name: " John ", last_name: "Doe")
        select "Nicht in der Liste enthalten", from: "Wohnort"

        fill_in "Stadt", with: "Bremen"
        fill_in "Postleitzahl", with: "33333"
        fill_in "Straße", with: "Haupstraße"
        fill_in "Hausnummer", with: "123"
        fill_in "Hausnummerergänzung", with: "B"
        click_button "Wohnsitz bestätigen"

        expect(page).to have_current_path(account_path)
        expect(User.count).to eq(1)
        expect(user.reload).to have_attributes(
          registered_address: nil,
          street_name: "Haupstraße",
          street_number: "123",
          street_number_extension: "B",
          plz: 33333,
          city_name: "Bremen",
          unique_stamp: nil,
          geozone_id: nil
        )
      end
    end

    context "when user's address is not among the existing registered addresses and is not valid" do
      it "does not send verification request" do
        fill_in_mandatory_fields_for_verification(first_name: " John ", last_name: "Doe")
        select "Nicht in der Liste enthalten", from: "Wohnort"

        fill_in "Postleitzahl", with: "33333"
        fill_in "Straße", with: "Haupstraße"
        fill_in "Hausnummer", with: "123"
        fill_in "Hausnummerergänzung", with: "B"
        click_button "Wohnsitz bestätigen"

        expect(page).to have_current_path(new_residence_path)
        expect(page).to have_text("Wir konnten Ihre Daten nicht verifizieren, bitte kontaktieren Sie uns.")
        expect(User.count).to eq(1)
        expect(user.reload).to have_attributes(
          registered_address: nil,
          city_name: nil,
          plz: 11111,
          street_name: nil,
          street_number: nil,
          street_number_extension: nil,
          unique_stamp: nil,
          geozone_id: nil
        )
      end
    end
  end
end
