section "Creating Projekts" do
  Projekt.create!(name: 'Test1')
  Projekt.create!(name: 'Test11')
  Projekt.create!(name: 'Test12')
  Projekt.create!(name: 'Test121')
  Projekt.create!(name: 'Test122')
  Projekt.create!(name: 'Test13')
  Projekt.create!(name: 'Test14')
  Projekt.create!(name: 'Test2')
  Projekt.create!(name: 'Test21')
  Projekt.create!(name: 'Test3')

  Projekt.all.map do |projekt| 
    projekt.page.update(
      status: 'published',
      content: Faker::Lorem.paragraph(sentence_count: 35)
    )
    projekt.projekt_settings.find_by(key: 'projekt_feature.main.activate').update(value: 'active')
    projekt.projekt_settings.find_by(key: 'projekt_feature.general.show_in_navigation').update(value: 'active')
  end
end
