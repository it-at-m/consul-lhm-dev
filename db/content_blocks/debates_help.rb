def debates_help_content
  content = '
		<p class="lead">
			<strong>Hilfe zu Diskussionen</strong>
		</p>
		<p>Teilen Sie ihre Meinung mit anderen in einer Diskussion über Themen, die Sie interessieren.</p>
		<p>Der Raum für Diskussionen richtet sich an alle, die ihr Anliegen darlegen können und sich mit anderen Menschen austauschen wollen.</p>
		<p>Um eine Diskussion zu eröffnen, müssen Sie sich auf <a href="/users/sign_up">CONSUL DEMO</a> registrieren. Benutzer*innen können auch offene Diskussionen kommentieren und sie über "Ich stimme zu" oder "Ich stimme nicht zu" Buttons bewerten.</p>
		<p></p>
  '
end

if SiteCustomization::ContentBlock.find_by(key: "debates_help").nil?
  content_block = SiteCustomization::ContentBlock.new(
    key: 'debates_help',
    name: 'custom',
    locale: 'de',
    body: debates_help_content
  )
  content_block.save!
end
