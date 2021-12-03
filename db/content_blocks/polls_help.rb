def polls_help_content
  content = '
    <p class="lead">
      <strong>Hilfe zur Abstimmung</strong>
    </p>
    <p>Bürgerumfragen sind ein partizipatorischer Mechanismus, mit dem Bürger mit Wahlrecht direkte Entscheidungen treffen können</p>
  '
end

if SiteCustomization::ContentBlock.find_by(key: "polls_help").nil?
  content_block = SiteCustomization::ContentBlock.new(
    key: 'polls_help',
    name: 'custom',
    locale: 'de',
    body: polls_help_content
  )
  content_block.save!
end
