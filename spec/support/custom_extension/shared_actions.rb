module CustomExtension
  module SharedActions
    def select_projekt_in_selector
      within "#projekt-selector-fields .projekt-selector .projekt_group" do
        find(".projekt", match: :first).click
      end
    end

    def fill_in_mandatory_fields_for_extended_registration(**options)
      fill_in "Benutzer*innenname", with: (options[:username] || "nutzer")
      fill_in "E-Mail", with: options[:email] || "nutzer@consul.dev"
      select options[:gender] || "männlich", from: "Geschlecht"
      fill_in "Vorname", with: options[:first_name] || "Max"
      fill_in "Nachname", with: options[:last_name] || "Mustermann"
      select_date "31-Dezember-1980", from: "user_date_of_birth"
      fill_in "Passwort", with: "12345678"
      fill_in "Passwort bestätigen", with: "12345678"
      check "Mit der Registrierung akzeptieren Sie, dass wir die hier erhobenen Daten zur Verarbeitung speichern."
      check "Mit der Registrierung akzeptieren Sie die Datenschutzvereinbarung"
      check "Mit der Registrierung akzeptieren Sie die Allgemeinen Nutzungsbedingungen"
    end

    def fill_in_mandatory_fields_for_verification(**options)
      fill_in "Vorname", with: options[:first_name] || "Max"
      fill_in "Nachname", with: options[:last_name] || "Mustermann"
      select_date "31-Dezember-1980", from: "residence_date_of_birth"
      select options[:gender] || "männlich", from: "Geschlecht"
      check "Mit der Registrierung akzeptieren Sie, dass wir die hier erhobenen Daten zur Verarbeitung speichern."
      check "Mit der Registrierung akzeptieren Sie die Datenschutzvereinbarung"
      check "Mit der Registrierung akzeptieren Sie die Allgemeinen Nutzungsbedingungen"
    end
  end
end
