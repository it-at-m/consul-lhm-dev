def debates_recommendations_content
  content = '
    <ul class="recommendations">
      <li>Verwenden Sie bitte nicht ausschließlich Großbuchstaben für die Überschrift oder für komplette Sätze. Im Internet gilt das als schreien. Und niemand möchte gerne angeschrien werden.</li>
      <li>Diskussionen oder Kommentare, die illegale Handlungen beinhalten, werden gelöscht sowie diejenigen, die die Diskussionen absichtlich sabotieren. Alles andere ist erlaubt.</li>
      <li>Kritik ist sehr willkommen. Denn dies ist ein Raum für unterschiedliche Betrachtungen. Aber wir empfehlen Ihnen, sich an sprachlicher Eleganz und Intelligenz zu halten. Die Welt ist ein besserer Ort mit diesen Tugenden.</li>
      <li>Genießen Sie diesen Ort und die Stimmen, die ihn füllen. Er gehört auch Ihnen.</li>
    </ul>
  '
end

if SiteCustomization::ContentBlock.find_by(key: "debates_creation_recommendations").nil?
  content_block = SiteCustomization::ContentBlock.new(
    key: 'debates_creation_recommendations',
    name: 'custom',
    locale: 'de',
    body: debates_recommendations_content
  )
  content_block.save!
end
