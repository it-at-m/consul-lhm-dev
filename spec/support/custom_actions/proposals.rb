module Proposals
  def custom_fill_in_proposal
    fill_in 'Titel des Vorschlages', with: "Titel des Vorschlages"
    fill_in 'Zusammenfassung Vorschlag', with: "Zusammenfassung Vorschlag..."
    # fill_in_ckeditor "Vorschlagstext", with: "Vorschlagstext..."
    fill_in "Externes Video URL", with: "https://www.youtube.com/watch?v=_51lRi-YJjk"
    check "Ich stimme der Datenschutzbestimmungen und den Allgemeine Nutzungsbedingungen zu"
  end
end
