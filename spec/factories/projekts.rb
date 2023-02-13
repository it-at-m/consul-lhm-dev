FactoryBot.define do
  factory :projekt do
    sequence(:name) { |n| "Projekt_#{SecureRandom.hex}" }

    total_duration_start { 1.month.ago }
    total_duration_end { 1.month.from_now }

    color { "#00AA02" }
    icon { "biking" }

    after(:create) do |projekt, evaluator|
      projekt.projekt_settings.find_by(key: "projekt_feature.main.activate").update!(value: "active")
      projekt.page.update!(status: "published", title: "Projekt page", content: "Lorem ipsum", locale: "de")
      projekt.debate_phase.update!(active: true, start_date: 1.month.ago, end_date: 1.month.from_now)
      projekt.proposal_phase.update!(active: true, start_date: 1.month.ago, end_date: 1.month.from_now)
      projekt.voting_phase.update!(active: true, start_date: 1.month.ago, end_date: 1.month.from_now)
    end

    factory :projekt_with_labels do
      after(:build) do |projekt, evaluator|
        projekt.projekt_labels << create(:projekt_label, projekt: projekt)
        projekt.projekt_labels << create(:projekt_label, projekt: projekt)
        projekt.projekt_labels << create(:projekt_label, projekt: projekt)
      end
    end
  end
end
