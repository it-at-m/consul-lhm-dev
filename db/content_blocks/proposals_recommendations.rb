def proposals_recommendations_content
  content = '
     <ul class="recommendations">
       <li>Do not use capital letters for the proposal title or for whole sentences. On the internet, this is considered shouting. And nobody likes being shouted at.</li>
       <li>Any proposal or comment suggesting illegal action will be deleted, as well as those intending to sabotage the debate spaces. Anything else is allowed.</li>
       <li>Enjoy this space and the voices that fill it. It belongs to you too.</li>
     </ul>
  '
end

if SiteCustomization::ContentBlock.find_by(key: "proposals_creation_recommendations").nil?
  content_block = SiteCustomization::ContentBlock.new(
    key: 'proposals_creation_recommendations',
    name: 'custom',
    locale: 'de',
    body: proposals_recommendations_content
  )
  content_block.save!
end
