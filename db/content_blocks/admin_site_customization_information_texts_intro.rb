def content
  '
    <p>Alle in Ihren Consul-Anwendungen verwendeten Textzeichenfolgen sind auf dieser Seite aufgeführt. Wenn Sie eine dieser Zeichenfolgen ändern möchten, brauchen Sie sie nur zu bearbeiten und auf die Schaltfläche "Speichern" unten auf dieser Seite zu klicken.</p>

    <p>Um die zu bearbeitende Zeichenfolge zu finden, rufen Sie die Suchfunktion Ihres Browsers auf und suchen Sie nach dem Text, den Sie ändern möchten. In den meisten Browsern können Sie das tun, indem Sie auf Strg+F klicken (oder Cmd+F, wenn Sie einen Mac verwenden). Es kann vorkommen, dass Sie mehrere Zeichenfolgen mit demselben Text finden. Das passiert, wenn derselbe Text an zwei (oder mehr) Stellen verwendet wird. Prüfen Sie in diesem Fall einfach den Schlüssel über dem Textfeld, das die Zeichenfolge enthält, und Sie erhalten einen Hinweis darauf, wo diese Zeichenfolge verwendet wird.</p>

    <p>Zum Beispiel zeigt der Schlüssel proposals.index.featured_proposals an, dass der Text im Textfeld darunter verwendet wird, um "featured proposals" auf der Indexseite für Vorschläge zu kennzeichnen.</p>
  '
end

if SiteCustomization::ContentBlock.find_by(key: "admin_site_customization_information_texts_intro").nil?
  content_block = SiteCustomization::ContentBlock.new(
    key: 'admin_site_customization_information_texts_intro',
    name: 'custom',
    locale: 'de',
    body: content
  )
  content_block.save!
end
