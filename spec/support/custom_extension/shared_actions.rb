module CustomExtension
  module SharedActions
    def select_projekt_in_selector
      within "#projekt-selector-fields .projekt-selector .projekt_group" do
        find(".projekt", match: :first).click
      end
    end

    def fill_in_mandatory_fields_for_extended_registration
      fill_in "Benutzer*innenname", with: "nutzer"
      fill_in "E-Mail", with: "nutzer@consul.dev"
      select "männlich", from: "Geschlecht"
      fill_in "Vorname", with: "Max"
      fill_in "Nachname", with: "Mustermann"
      select_date "31-Dezember-1980", from: "user_date_of_birth"
      fill_in "Passwort", with: "12345678"
      fill_in "Passwort bestätigen", with: "12345678"
      check "Mit der Registrierung akzeptieren Sie die Allgemeine Nutzungsbedingungen und Datenschutzbestimmung"
    end
  end
end
