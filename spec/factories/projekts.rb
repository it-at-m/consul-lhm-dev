FactoryBot.define do
  factory :projekt do
    sequence(:name) { |n| "Projekt_#{SecureRandom.hex}" }

    total_duration_start { 1.month.ago }
    total_duration_end { 1.month.from_now }

    color { "#00AA02" }
    icon { "biking" }

    factory :projekt_with_labels do
      after(:create) do |projekt, evaluator|
        projekt.labels << create(:projekt_label)
      end
    end
  end
end
