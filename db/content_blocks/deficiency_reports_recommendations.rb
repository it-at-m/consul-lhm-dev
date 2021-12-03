def deficiency_reports_recommendations_content
  content = '<ul class="recommendations">'
  content += "<li>#{I18n.t('custom.deficiency_reports.new.recommendation_one')}</li>"
  content += "<li>#{I18n.t('custom.deficiency_reports.new.recommendation_two')}</li>"
  content += "<li>#{I18n.t('custom.deficiency_reports.new.recommendation_three')}</li>"
  content += '</ul>'
end

if SiteCustomization::ContentBlock.find_by(key: "deficiency_reports_creation_recommendations").nil?
  content_block = SiteCustomization::ContentBlock.new(
    key: 'deficiency_reports_creation_recommendations',
    name: 'custom',
    locale: 'de',
    body: deficiency_reports_recommendations_content
  )
  content_block.save!
end
