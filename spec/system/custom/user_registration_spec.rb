require "rails_helper"

describe "UserRegistration" do
  context "when extended registraion is enabled" do
    before do
      Setting["extra_fields.registration.extended"] = true

      registered_address_street = create(:registered_address_street, name: "Teststraße", plz: "12345")
      registered_address_city = create(:registered_address_city, name: "Teststadt")

      create_list(:registered_address, 5,
                  registered_address_street: registered_address_street,
                  registered_address_city: registered_address_city
                 )
    end

    context "when user's address is among the existing registered addresses" do
      it "creates a user and links them to registered address" do
        visit new_user_registration_path(locale: :de)
        fill_in "Benutzer*innenname", with: "nutzer"
        fill_in "E-Mail", with: "nutzer@consul.dev"
        select "männlich", from: "Geschlecht"
        fill_in "Vorname", with: "Max"
        fill_in "Nachname", with: "Mustermann"
        select "Teststadt", from: "Wohnort"
        select "Teststraße (12345)", from: "Straße"
        select "Teststraße 2a", from: "Adresse"
        select_date "31-Dezember-1980", from: "user_date_of_birth"
        fill_in "Passwort", with: "12345678"
        fill_in "Passwort bestätigen", with: "12345678"
        check "Mit der Registrierung akzeptieren Sie die Allgemeine Nutzungsbedingungen und Datenschutzbestimmung"
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
          street_number_extension: "a"
        )
      end
    end

    context "when user's city is not listed in selector" do
      it "creates a user with a custom address" do
        visit new_user_registration_path(locale: :de)
        fill_in "Benutzer*innenname", with: "nutzer"
        fill_in "E-Mail", with: "nutzer@consul.dev"
        select "weiblich", from: "Geschlecht"
        fill_in "Vorname", with: "Erika"
        fill_in "Nachname", with: "Mustermann"
        select "Nicht in der Liste enthalten", from: "Wohnort"
        fill_in "Stadt", with: "Berlin"
        fill_in "Postleitzahl", with: "54321"
        fill_in "Straße", with: "Unter den Linden"
        fill_in "Hausnummer", with: "100"
        fill_in "Hausnummerergänzung", with: "C"
        select_date "31-Dezember-1980", from: "user_date_of_birth"
        fill_in "Passwort", with: "12345678"
        fill_in "Passwort bestätigen", with: "12345678"
        check "Mit der Registrierung akzeptieren Sie die Allgemeine Nutzungsbedingungen und Datenschutzbestimmung"
        click_button "Registrieren"
        expect(User.count).to eq(1)
        expect(User.first.registered_address).not_to be_present
        expect(User.first).to have_attributes(
          username: "nutzer",
          email: "nutzer@consul.dev",
          gender: "female",
          first_name: "Erika",
          last_name: "Mustermann",
          date_of_birth: Time.zone.local(1980, 12, 31),
          city_name: "Berlin",
          plz: 54321,
          street_name: "Unter den Linden",
          street_number: "100",
          street_number_extension: "C"
        )
      end
    end

    context "when user's street is not listed selector" do
      it "creates a user with a custom address" do
        visit new_user_registration_path(locale: :de)
        fill_in "Benutzer*innenname", with: "nutzer"
        fill_in "E-Mail", with: "nutzer@consul.dev"
        select "weiblich", from: "Geschlecht"
        fill_in "Vorname", with: "Erika"
        fill_in "Nachname", with: "Mustermann"
        select "Teststadt", from: "Wohnort"
        select "Nicht in der Liste enthalten", from: "Straße"
        fill_in "Stadt", with: "Munich"
        fill_in "Postleitzahl", with: "11111"
        fill_in "Straße", with: "Marienplatz"
        fill_in "Hausnummer", with: "111"
        fill_in "Hausnummerergänzung", with: "B"
        select_date "31-Dezember-1980", from: "user_date_of_birth"
        fill_in "Passwort", with: "12345678"
        fill_in "Passwort bestätigen", with: "12345678"
        check "Mit der Registrierung akzeptieren Sie die Allgemeine Nutzungsbedingungen und Datenschutzbestimmung"
        click_button "Registrieren"
        expect(User.count).to eq(1)
        expect(User.first.registered_address).not_to be_present
        expect(User.first).to have_attributes(
          username: "nutzer",
          email: "nutzer@consul.dev",
          gender: "female",
          first_name: "Erika",
          last_name: "Mustermann",
          date_of_birth: Time.zone.local(1980, 12, 31),
          city_name: "Munich",
          plz: 11111,
          street_name: "Marienplatz",
          street_number: "111",
          street_number_extension: "B"
        )
      end
    end

    context "when user's street is not listed selector" do
      it "creates a user with a custom address" do
        visit new_user_registration_path(locale: :de)
        fill_in "Benutzer*innenname", with: "nutzer"
        fill_in "E-Mail", with: "nutzer@consul.dev"
        select "weiblich", from: "Geschlecht"
        fill_in "Vorname", with: "Erika"
        fill_in "Nachname", with: "Mustermann"
        select "Teststadt", from: "Wohnort"
        select "Teststraße (12345)", from: "Straße"
        select "Nicht in der Liste enthalten", from: "Adresse"
        fill_in "Stadt", with: "Hamburg"
        fill_in "Postleitzahl", with: "22222"
        fill_in "Straße", with: "Reeperbahn"
        fill_in "Hausnummer", with: "99"
        select_date "31-Dezember-1980", from: "user_date_of_birth"
        fill_in "Passwort", with: "12345678"
        fill_in "Passwort bestätigen", with: "12345678"
        check "Mit der Registrierung akzeptieren Sie die Allgemeine Nutzungsbedingungen und Datenschutzbestimmung"
        click_button "Registrieren"
        expect(User.count).to eq(1)
        expect(User.first.registered_address).not_to be_present
        expect(User.first).to have_attributes(
          username: "nutzer",
          email: "nutzer@consul.dev",
          gender: "female",
          first_name: "Erika",
          last_name: "Mustermann",
          date_of_birth: Time.zone.local(1980, 12, 31),
          city_name: "Hamburg",
          plz: 22222,
          street_name: "Reeperbahn",
          street_number: "99",
          street_number_extension: ""
        )
      end
    end
  end
end
