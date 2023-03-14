require "rails_helper"

describe "UserRegistration" do
  context "when extended registraion is enabled" do
    before do
      registered_address_street = create(:registered_address_street, name: "Teststraße")
      create_list(:registered_address, 5, registered_address_street: registered_address_street, city: "Teststadt")
      Setting["extra_fields.registration.extended"] = true
    end

    context "when the user is valid" do
      context "when user's address is among the existing registered addresses" do
        it "creates a user" do
          visit new_user_registration_path(locale: :de)
          fill_in "Benutzer*innenname", with: "nutzer"
          fill_in "E-Mail", with: "nutzer@consul.dev"
          select "männlich", from: "Geschlecht"
          fill_in "Vorname", with: "Max"
          fill_in "Nachname", with: "Mustermann"
          select "Teststadt", from: "Stadt"
          select "Teststraße (12345)", from: "Straße"
          select "1a", from: "Hausnummer"
          select_date "31-Dezember-1980", from: "user_date_of_birth"
          fill_in "Passwort", with: "12345678"
          fill_in "Passwort bestätigen", with: "12345678"
          check "Mit der Registrierung akzeptieren Sie die Allgemeine Nutzungsbedingungen und Datenschutzbestimmung"
          click_button "Registrieren"

          expect(User.count).to eq(1)
          expect(User.first.registered_address).to eq(RegisteredAddress.first)
          expect(User.first.registered_address_street).to eq(RegisteredAddressStreet.first)
        end
      end

      xcontext "when user's street is not among the existing registered addresses" do
        it "creates a user" do
          visit new_user_registration_path(locale: :de)
          fill_in "Benutzer*innenname", with: "nutzer"
          fill_in "E-Mail", with: "nutzer@consul.dev"
          fill_in "Vorname", with: "Max"
          fill_in "Nachname", with: "Mustermann"
          select "not in the list", from: "Straße"
          fill_in "Hausnummer", with: "1"
          fill_in "Hausnummerzusatz", with: "a"
          fill_in "Postleitzahl", with: "12345"
          fill_in "Stadt", with: "Teststadt"
          select_date "31-Dezember-1980", from: "user_date_of_birth"
          select "männlich", from: "Geschlecht"
          fill_in "Passwort", with: "12345678"
          fill_in "Passwort bestätigen", with: "12345678"
          check "Mit der Registrierung akzeptieren Sie die Allgemeine Nutzungsbedingungen und Datenschutzbestimmung"
          click_button "Registrieren"

          expect(User.count).to eq(1)
        end
      end
    end
  end
end
