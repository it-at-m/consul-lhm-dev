def deficiency_reports_help_content
  content = '
    <p class="lead">
      <strong>Hilfe zu Mängelmeldungen</strong>
    </p>
    <p>Mängel können, abhängig vom eingestellten Verifizierungsverfahren, von jeder Benutzerin und jedem Benutzer eingebracht werden. Sie bieten eine einfache Möglichkeit auf Mängel in der Stadt hinzuweisen. Wir danken für Ihre Unterstützung!</p>
  '
end

if SiteCustomization::ContentBlock.find_by(key: "deficiency_reports_help").nil?
  content_block = SiteCustomization::ContentBlock.new(
    key: 'deficiency_reports_help',
    name: 'custom',
    locale: 'de',
    body: deficiency_reports_help_content
  )
  content_block.save!
end
