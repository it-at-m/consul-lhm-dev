require "rails_helper"

describe "User registration" do
  context "when extended registraion is not enabled" do
    before do
      Setting["extra_fields.registration.extended"] = false
    end

    it "creates a user" do
      visit new_user_registration_path(locale: :de)
      fill_in "Benutzer*innenname", with: "nutzer"
      fill_in "E-Mail", with: "nutzer@consul.dev"
      fill_in "Passwort", with: "12345678"
      fill_in "Passwort bestätigen", with: "12345678"
      check "Mit der Registrierung akzeptieren Sie, dass wir die hier erhobenen Daten zur Verarbeitung speichern."
      check "Mit der Registrierung akzeptieren Sie die Datenschutzvereinbarung"
      check "Mit der Registrierung akzeptieren Sie die Allgemeinen Nutzungsbedingungen"
      click_button "Registrieren"

      expect(page).not_to have_content("Wohnort")
      expect(page).not_to have_content("Postleitzahl")
      expect(User.count).to eq(1)
      expect(User.first).to have_attributes(
        username: "nutzer",
        email: "nutzer@consul.dev",
        unique_stamp: nil,
        geozone: nil
      )
    end
  end

  context "when extended registraion is enabled but there are no registered addresses" do
    before do
      Setting["extra_fields.registration.extended"] = true
    end

    it "creates a user" do
      visit new_user_registration_path(locale: :de)
      expect(page).not_to have_content("Wohnort")

      fill_in_mandatory_fields_for_extended_registration

      fill_in "Stadt", with: "Bremen"
      fill_in "Postleitzahl", with: "33333"
      fill_in "Straße", with: "Haupstraße"
      fill_in "Hausnummer", with: "123"
      fill_in "Hausnummerergänzung", with: "B"

      click_button "Registrieren"

      expect(User.count).to eq(1)
      expect(User.first.registered_address).not_to be_present
      expect(User.first).to have_attributes(
        username: "nutzer",
        email: "nutzer@consul.dev",
        city_name: "Bremen",
        plz: 33333,
        street_name: "Haupstraße",
        street_number: "123",
        street_number_extension: "B",
        unique_stamp: nil,
        geozone: nil
      )
    end
  end

  context "when extended registraion is enabled and registered addresses are present" do
    before do
      Setting["extra_fields.registration.extended"] = true

      FactoryBot.rewind_sequences
      registered_address_street = create(:registered_address_street, name: "Teststraße", plz: "12345")
      registered_address_city = create(:registered_address_city, name: "Teststadt")
      create_list(:registered_address, 5,
                  registered_address_street: registered_address_street,
                  registered_address_city: registered_address_city)
    end

    context "when user's address is among the existing registered addresses" do
      it "creates a user and links them to registered address" do
        visit new_user_registration_path(locale: :de)
        fill_in_mandatory_fields_for_extended_registration
        select "Teststadt", from: "Wohnort"
        select "Teststraße (12345)", from: "Straße"
        select "Teststraße 2a", from: "Adresse"
        click_button "Registrieren"

        expect(page).not_to have_content("Postleitzahl")
        expect(User.count).to eq(1)
        expect(User.first.registered_address).to eq(RegisteredAddress.second)
        expect(User.first.registered_address_street).to eq(RegisteredAddress::Street.first)
        expect(User.first).to have_attributes(
          username: "nutzer",
          email: "nutzer@consul.dev",
          gender: "male",
          first_name: "Max",
          last_name: "Mustermann",
          date_of_birth: Time.zone.local(1980, 12, 31),
          city_name: "Teststadt",
          plz: 12345,
          street_name: "Teststraße",
          street_number: "2",
          street_number_extension: "a",
          unique_stamp: nil,
          geozone: nil
        )
      end
    end

    context "when user's city is not listed in selector" do
      it "creates a user with a custom address" do
        visit new_user_registration_path(locale: :de)
        fill_in_mandatory_fields_for_extended_registration
        select "Nicht in der Liste enthalten", from: "Wohnort"
        fill_in "Stadt", with: "Berlin"
        fill_in "Postleitzahl", with: "54321"
        fill_in "Straße", with: "Unter den Linden"
        fill_in "Hausnummer", with: "100"
        fill_in "Hausnummerergänzung", with: "C"
        click_button "Registrieren"

        expect(User.count).to eq(1)
        expect(User.first.registered_address).not_to be_present
        expect(User.first).to have_attributes(
          username: "nutzer",
          email: "nutzer@consul.dev",
          gender: "male",
          first_name: "Max",
          last_name: "Mustermann",
          date_of_birth: Time.zone.local(1980, 12, 31),
          city_name: "Berlin",
          plz: 54321,
          street_name: "Unter den Linden",
          street_number: "100",
          street_number_extension: "C",
          unique_stamp: nil,
          geozone: nil
        )
      end
    end

    context "when document is required and user user's address is among the existing registered addresses" do
      before do
        Setting["extra_fields.registration.check_documents"] = true
      end

      it "creates a user and links them to registered address" do
        visit new_user_registration_path(locale: :de)
        fill_in_mandatory_fields_for_extended_registration
        select "Teststadt", from: "Wohnort"
        select "Teststraße (12345)", from: "Straße"
        select "Teststraße 2a", from: "Adresse"

        select "Personalausweis", from: "Dokument"
        fill_in "Personalausweis / Passport (4 letzten Ziffern)", with: "1234"

        click_button "Registrieren"

        expect(User.count).to eq(1)
        expect(User.first.registered_address).to eq(RegisteredAddress.second)
        expect(User.first.registered_address_street).to eq(RegisteredAddress::Street.first)
        expect(User.first).to have_attributes(
          username: "nutzer",
          email: "nutzer@consul.dev",
          gender: "male",
          first_name: "Max",
          last_name: "Mustermann",
          date_of_birth: Time.zone.local(1980, 12, 31),
          city_name: "Teststadt",
          plz: 12345,
          street_name: "Teststraße",
          street_number: "2",
          street_number_extension: "a",
          document_type: "card",
          document_last_digits: "1234",
          unique_stamp: nil,
          geozone: nil
        )
      end
    end
  end
end
