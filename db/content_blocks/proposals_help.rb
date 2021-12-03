def proposals_help_content
  content = '
    <p class="lead">
      <strong>Hilfe zu Vorschlägen</strong>
    </p>
    <p>Vorschläge können, abhängig vom eingestellten Verifizierungsverfahren, von jeder Benutzerin und jedem Benutzer eingebracht werden. Sie bieten eine einfache Möglichkeit, eigene Ideen oder Verbesserungsvorschläge einzubringen und für deren Unterstützung zu werben.</p>
  '
end

if SiteCustomization::ContentBlock.find_by(key: "proposals_help").nil?
  content_block = SiteCustomization::ContentBlock.new(
    key: 'proposals_help',
    name: 'custom',
    locale: 'de',
    body: proposals_help_content
  )
  content_block.save!
end
